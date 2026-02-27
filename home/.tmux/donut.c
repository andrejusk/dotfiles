/*
 * Spinning donut screensaver with matrix rain.
 * Compile: cc -O2 -o donut donut.c -lm
 * Press any key to quit.
 */
#include <math.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/time.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

static struct termios orig_termios;
static volatile sig_atomic_t running = 1;

static void restore_tmux(void) {
    system("tmux set-option status on 2>/dev/null");
}

static void cleanup(void) {
    printf("\033[?1006l\033[?1000l\033[?1049l\033[?25h\033[0m");  /* SGR off + mouse off + main screen + cursor + reset */
    fflush(stdout);
    /* Drain any leftover input (partial mouse/key escape sequences) */
    tcflush(STDIN_FILENO, TCIFLUSH);
    tcsetattr(STDIN_FILENO, TCSANOW, &orig_termios);
    restore_tmux();
}

static void handle_sig(int s) { (void)s; running = 0; }

static void write_all(int fd, const char *buf, int len) {
    while (len > 0) {
        ssize_t n = write(fd, buf, len);
        if (n <= 0) { running = 0; return; }
        buf += n;
        len -= n;
    }
}

/* 64 foreground-color escapes: teal color ramp. */
#define N_SHADES 64
static char SHADE_ESC[N_SHADES][28];
static int  SHADE_LEN[N_SHADES];

/* Fixed escape sequences with known lengths */
#define ESC_RESET     "\033[0m"
#define ESC_RESET_LEN (sizeof(ESC_RESET) - 1)
#define ESC_CLK_FG     "\033[38;2;44;180;148m"
#define ESC_CLK_FG_LEN (sizeof(ESC_CLK_FG) - 1)
#define ESC_CLK_SH     "\033[38;2;10;40;34m"
#define ESC_CLK_SH_LEN (sizeof(ESC_CLK_SH) - 1)
#define ESC_ROWEND     "\033[0m\033[K"
#define ESC_ROWEND_LEN (sizeof(ESC_ROWEND) - 1)

/* Read input, return 1 if should quit. Ignores mouse release events.
 * X11 basic: \033[M btn x y (release: btn & 3 == 3)
 * SGR extended: \033[<btn;x;yM (press) or \033[<btn;x;ym (release) */
static int check_quit(void) {
    char ch;
    if (read(STDIN_FILENO, &ch, 1) != 1) return 0;
    if (ch == '\033') {
        /* Read remaining escape sequence */
        char seq[32];
        int len = 0;
        while (len < 30) {
            if (read(STDIN_FILENO, &seq[len], 1) != 1) break;
            char c = seq[len++];
            /* SGR mouse ends with M (press) or m (release) */
            if (c == 'm') return 0;  /* release — ignore */
            if (c == 'M') {
                /* Could be X11 basic or SGR press */
                if (len >= 2 && seq[0] == '[' && seq[1] == '<') return 1;  /* SGR press */
                /* X11 basic: \033[M followed by 3 raw bytes */
                if (len == 2) { /* read remaining 3 bytes */
                    char raw[3] = {0}; int got = 0;
                    while (got < 3) { if (read(STDIN_FILENO, &raw[got], 1) == 1) got++; else break; }
                    if (got == 3 && (raw[0] & 3) == 3) return 0;  /* X11 release */
                }
                return 1;  /* press */
            }
            /* Regular escape sequence (arrows etc) ends at alpha */
            if (c >= 'A' && c <= 'Z' && c != 'M') return 1;
            if (c >= 'a' && c <= 'z' && c != 'm') return 1;
        }
        return 1;
    }
    return 1;  /* regular key */
}
enum { CS_RESET = -1, CS_CLK_FG = -2, CS_CLK_SH = -3 };

static void init_palette(float dim) {
    for (int i = 0; i < N_SHADES; i++) {
        float t = (float)i / (N_SHADES - 1);
        int r, g, b;
        if (t <= 0.45f) {
            float s = t / 0.45f;
            r = 4  + (int)((44  - 4)  * s);
            g = 20 + (int)((180 - 20) * s);
            b = 16 + (int)((148 - 16) * s);
        } else {
            float s = (t - 0.45f) / 0.55f;
            r = 44  + (int)((196 - 44)  * s);
            g = 180 + (int)((236 - 180) * s);
            b = 148 + (int)((216 - 148) * s);
        }
        r = (int)(r * dim); g = (int)(g * dim); b = (int)(b * dim);
        SHADE_LEN[i] = sprintf(SHADE_ESC[i], "\033[38;2;%d;%d;%dm", r, g, b);
    }
}

/* Matrix rain character set */
static const char MCHARS[] =
    "0123456789"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "abcdefghijklmnopqrstuvwxyz"
    "!@#$%^&*+-=<>~";
#define N_MCHARS ((int)(sizeof(MCHARS) - 1))

/* Matrix rain state — per column */
#define MAX_W 400
#define MAX_H 200
static float mat_head[MAX_W];      /* head position (fractional row) */
static float mat_speed[MAX_W];     /* rows per frame */
static int   mat_trail[MAX_W];     /* trail length */
static char  mat_grid[MAX_H][MAX_W]; /* character at each cell */

static void mat_init_col(int c, int H) {
    mat_head[c] = -(rand() % H);
    mat_speed[c] = 0.15f + (rand() / (float)RAND_MAX) * 0.35f;
    mat_trail[c] = 20 + rand() % 40;
}

static void mat_update(int W, int H, float dt);

static void mat_init(int W, int H) {
    for (int c = 0; c < W; c++) mat_init_col(c, H);
    for (int r = 0; r < MAX_H; r++)
        for (int c = 0; c < MAX_W; c++)
            mat_grid[r][c] = MCHARS[rand() % N_MCHARS];
    /* Pre-simulate so rain covers screen from frame 1 */
    for (int i = 0; i < H * 3; i++) mat_update(W, H, 1.0f);
}

static void mat_update(int W, int H, float dt) {
    for (int c = 0; c < W; c++) {
        mat_head[c] += mat_speed[c] * dt;
        /* Respawn when trail fully offscreen */
        if ((int)mat_head[c] - mat_trail[c] > H) mat_init_col(c, H);
        /* Flicker: randomly change char at head */
        int hr = (int)mat_head[c];
        if (hr >= 0 && hr < H)
            mat_grid[hr][c] = MCHARS[rand() % N_MCHARS];
    }
    /* Sparse flicker across grid */
    int flickers = W * H / 200;
    for (int i = 0; i < flickers; i++) {
        int r = rand() % H, c = rand() % W;
        mat_grid[r][c] = MCHARS[rand() % N_MCHARS];
    }
}

static char mat_char_at(int r, int c) {
    int hr = (int)mat_head[c];
    if (r <= hr && r > hr - mat_trail[c])
        return mat_grid[r][c];
    return 0;
}

/* Chunky digit font: 7 rows x 5 cols */
static const char *BFONT[10][7] = {
    {" ### ","#   #","#   #","#   #","#   #","#   #"," ### "},  /* 0 */
    {"  #  "," ##  ","  #  ","  #  ","  #  ","  #  "," ### "},  /* 1 */
    {" ### ","#   #","    #","  ## "," #   ","#    ","#####"},  /* 2 */
    {" ### ","#   #","    #"," ### ","    #","#   #"," ### "},  /* 3 */
    {"   # ","  ## "," # # ","#  # ","#####","   # ","   # "},  /* 4 */
    {"#####","#    ","#### ","    #","    #","#   #"," ### "},  /* 5 */
    {" ### ","#    ","#    ","#### ","#   #","#   #"," ### "},  /* 6 */
    {"#####","    #","   # ","  #  "," #   "," #   "," #   "},  /* 7 */
    {" ### ","#   #","#   #"," ### ","#   #","#   #"," ### "},  /* 8 */
    {" ### ","#   #","#   #"," ####","    #","    #"," ### "},  /* 9 */
};

/* Layout:  D D : D D
 * digit = 5 font cols x 2 term cols = 10 cols
 * colon = 2 cols (dots at rows 2 and 4)
 * gaps  = 2 cols between glyphs
 * Total = 10+2+10+2+2+2+10+2+10 = 50 cols */
#define CLK_PX_W 50
#define CLK_PX_H 7

/* Returns: 1=lit, 0=unlit */
static int clock_pixel(int row, int col, const int hhmm[4], int blink_on) {
    /* D0: 0-9, gap: 10-11, D1: 12-21, gap: 22-23, colon: 24-25, gap: 26-27, D2: 28-37, gap: 38-39, D3: 40-49 */
    static const int gx[] = {0, 12, 28, 40};
    for (int d = 0; d < 4; d++) {
        int x0 = gx[d];
        if (col >= x0 && col < x0 + 10) {
            int fc = (col - x0) / 2;
            return BFONT[hhmm[d]][row][fc] == '#' ? 1 : 0;
        }
    }
    /* Colon: cols 24-25, lit at rows 2 and 4 */
    if (col >= 24 && col <= 25) {
        if (!blink_on) return 0;
        return (row == 2 || row == 4) ? 1 : 0;
    }
    return 0;
}

/* Shadow: same as face but offset +1 row, +1 col */
static int clock_shadow(int row, int col, const int hhmm[4], int blink_on) {
    if (row < 1 || col < 1) return 0;
    return clock_pixel(row - 1, col - 1, hhmm, blink_on);
}

int main(int argc, char **argv) {
    init_palette(1.0f);

    /* Read active time from argv (passed once at lock) */
    int active_secs = 0;
    if (argc > 1) active_secs = atoi(argv[1]);
    char activity_str[64] = "";
    int activity_len = 0;
    if (active_secs > 0) {
        int h = active_secs / 3600, m = (active_secs % 3600) / 60;
        if (h > 0 && m > 0)
            activity_len = sprintf(activity_str, "%d hour%s %d minute%s active today",
                                   h, h == 1 ? "" : "s", m, m == 1 ? "" : "s");
        else if (h > 0)
            activity_len = sprintf(activity_str, "%d hour%s active today", h, h == 1 ? "" : "s");
        else
            activity_len = sprintf(activity_str, "%d minute%s active today", m, m == 1 ? "" : "s");
    }

    tcgetattr(STDIN_FILENO, &orig_termios);
    atexit(cleanup);
    signal(SIGINT, handle_sig);
    signal(SIGTERM, handle_sig);
    signal(SIGPIPE, handle_sig);

    struct termios raw = orig_termios;
    raw.c_lflag &= ~(ICANON | ECHO);
    raw.c_cc[VMIN] = 0;
    raw.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSANOW, &raw);

    system("tmux set-option status off 2>/dev/null");

    printf("\033[?1049h\033[?25l\033[?1000h\033[?1006h");  /* alt screen + hide cursor + mouse + SGR mode */
    fflush(stdout);

    const float R1 = 1.0f, R2 = 2.0f;
    const float theta_step = 0.02f, phi_step = 0.005f;

    const int n_theta = (int)(6.2832f / theta_step) + 1;
    const int n_phi   = (int)(6.2832f / phi_step) + 1;
    float *cos_theta = malloc(n_theta * sizeof(float));
    float *sin_theta = malloc(n_theta * sizeof(float));
    float *cos_phi   = malloc(n_phi * sizeof(float));
    float *sin_phi   = malloc(n_phi * sizeof(float));

    for (int i = 0; i < n_theta; i++) {
        float t = i * theta_step;
        cos_theta[i] = cosf(t);
        sin_theta[i] = sinf(t);
    }
    for (int i = 0; i < n_phi; i++) {
        float p = i * phi_step;
        cos_phi[i] = cosf(p);
        sin_phi[i] = sinf(p);
    }

    float *zbuf = malloc(MAX_W * MAX_H * sizeof(float));
    float *lbuf = malloc(MAX_W * MAX_H * sizeof(float));
    int   *sbuf = malloc(MAX_W * MAX_H * sizeof(int));
    char  *out  = malloc(MAX_W * MAX_H * 30 + MAX_H * 25 + 4096);

    struct timeval tv_start, tv_end, tv_boot;
    gettimeofday(&tv_boot, NULL);
    srand((unsigned)tv_boot.tv_usec);

    mat_init(MAX_W, MAX_H);

    float A = (rand() / (float)RAND_MAX) * 6.2832f;
    float B = (rand() / (float)RAND_MAX) * 6.2832f;
    float dA = 0.025f + (rand() / (float)RAND_MAX) * 0.035f;
    float dB = 0.015f + (rand() / (float)RAND_MAX) * 0.025f;
    if (rand() % 2) dA = -dA;
    if (rand() % 2) dB = -dB;

    int drift_ox = 0, drift_oy = 0;
    int clk_dx = 0, clk_dy = 0;
    int drift_tick = 0;
    float last_dim = 1.0f;
    struct timeval tv_prev;
    gettimeofday(&tv_prev, NULL);
    float dt_scale = 1.0f;
    int frame_count = 0;

    while (running) {
        gettimeofday(&tv_start, NULL);

        /* Time-based movement: scale all motion by actual frame delta */
        float dt_ms = (tv_start.tv_sec - tv_prev.tv_sec) * 1000.0f
                    + (tv_start.tv_usec - tv_prev.tv_usec) / 1000.0f;
        tv_prev = tv_start;

        /* Resumed from sleep/screen lock — discard stale buffered frames */
        if (dt_ms > 500.0f) {
            tcflush(STDOUT_FILENO, TCOFLUSH);
            dt_scale = 1.0f;
            continue;
        }

        if (dt_ms > 1.0f) dt_scale = dt_ms / 41.6f;
        if (dt_scale > 4.0f) dt_scale = 4.0f;

        float elapsed_s = (tv_start.tv_sec - tv_boot.tv_sec)
                        + (tv_start.tv_usec - tv_boot.tv_usec) / 1e6f;

        float dim = 0.3f + 0.7f / (1.0f + elapsed_s / 900.0f);
        if (fabsf(dim - last_dim) > 0.005f) {
            init_palette(dim);
            last_dim = dim;
        }

        int new_tick = (int)(elapsed_s / 180.0f);
        if (new_tick != drift_tick) {
            drift_tick = new_tick;
            drift_ox = (rand() % 21) - 10;
            drift_oy = (rand() % 7)  - 3;
            clk_dx = (rand() % 41) - 20;
            clk_dy = (rand() % 21) - 10;
        }

        struct winsize ws;
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws);
        int W = ws.ws_col;
        int H = ws.ws_row;
        if (W > MAX_W) W = MAX_W;
        if (H > MAX_H) H = MAX_H;
        if (W < 10 || H < 5) { usleep(100000); continue; }

        mat_update(W, H, dt_scale);

        int sz = W * H;

        /* Projection rate follows dim curve: bright=24fps → dim=6fps */
        int proj_skip = (int)((1.0f - dim) * 4.0f) + 1;
        if (proj_skip > 4) proj_skip = 4;

        /* 3D projection at reduced rate — sbuf cached between updates */
        if (frame_count % proj_skip == 0) {
            float K2 = 5.0f;
            /* Cap projection to reference size — donut stays same size on any screen */
            int proj_w = W < 160 ? W : 160;
            float K1 = proj_w * K2 * 3.0f / (8.0f * (R1 + R2));
            int half_w = W / 2 + drift_ox;
            int half_h = H / 2 + drift_oy;

            memset(zbuf, 0, sz * sizeof(float));
            for (int i = 0; i < sz; i++) lbuf[i] = -1.0f;

            float cA = cosf(A), sA = sinf(A);
            float cB = cosf(B), sB = sinf(B);
            float cAsB = cA*sB, cAcB = cA*cB;
            float sAsB = sA*sB, sAcB = sA*cB;

            for (int ti = 0; ti < n_theta; ti++) {
                float ct = cos_theta[ti], st = sin_theta[ti];
                float cx = R2 + R1 * ct;
                float cy = R1 * st;

                for (int pi = 0; pi < n_phi; pi++) {
                    float cp = cos_phi[pi], sp = sin_phi[pi];

                    float x = cx*(cB*cp + sAsB*sp) - cy*cAsB;
                    float y = cx*(sB*cp - sAcB*sp) + cy*cAcB;
                    float z = cA*cx*sp + cy*sA;
                    float ooz = 1.0f / (z + K2);

                    int px = (int)(half_w + K1*ooz*x);
                    int py = (int)(half_h - K1*ooz*y*0.5f);

                    if (px >= 0 && px < W && py >= 0 && py < H) {
                        int idx = py*W + px;
                        if (ooz > zbuf[idx]) {
                            zbuf[idx] = ooz;
                            float L = cp*ct*sB - cA*ct*sp - sA*st
                                      + cB*(cA*st - ct*sA*sp);
                            if (L < 0.0f) L = 0.0f;
                            L = 0.05f + L * 0.65f;
                            lbuf[idx] = L;
                        }
                    }
                }
            }

            /* Gap fill */
            for (int r = 1; r < H-1; r++) {
                int rs = r * W;
                for (int c = 1; c < W-1; c++) {
                    int idx = rs + c;
                    if (lbuf[idx] >= 0.0f) continue;
                    int n = 0;
                    float sum = 0, v;
                    if ((v = lbuf[idx-1])   >= 0) { n++; sum += v; }
                    if ((v = lbuf[idx+1])   >= 0) { n++; sum += v; }
                    if ((v = lbuf[idx-W])   >= 0) { n++; sum += v; }
                    if ((v = lbuf[idx+W])   >= 0) { n++; sum += v; }
                    if ((v = lbuf[idx-W-1]) >= 0) { n++; sum += v; }
                    if ((v = lbuf[idx-W+1]) >= 0) { n++; sum += v; }
                    if ((v = lbuf[idx+W-1]) >= 0) { n++; sum += v; }
                    if ((v = lbuf[idx+W+1]) >= 0) { n++; sum += v; }
                    if (n >= 5) lbuf[idx] = sum / n;
                }
            }

            /* Quantize luminance → shade indices */
            for (int i = 0; i < sz; i++) {
                if (lbuf[i] < 0.0f) {
                    sbuf[i] = -1;
                } else {
                    int ci = (int)(lbuf[i] * (N_SHADES - 1));
                    sbuf[i] = ci < N_SHADES ? ci : N_SHADES - 1;
                }
            }

            /* Rim lighting + subtle ambient occlusion */
            for (int r = 1; r < H-1; r++) {
                int rs = r * W;
                for (int c = 1; c < W-1; c++) {
                    int idx = rs + c;
                    if (sbuf[idx] < 0) continue;
                    int empty_n = (sbuf[idx-1]<0)+(sbuf[idx+1]<0)+(sbuf[idx-W]<0)+(sbuf[idx+W]<0);
                    if (empty_n > 0) {
                        int filled = (sbuf[idx-1]>=0)+(sbuf[idx+1]>=0)+(sbuf[idx-W]>=0)+(sbuf[idx+W]>=0)
                                    +(sbuf[idx-W-1]>=0)+(sbuf[idx-W+1]>=0)+(sbuf[idx+W-1]>=0)+(sbuf[idx+W+1]>=0);
                        if (filled >= 6) {
                            /* Inner hole edge — subtle darken */
                            int ci = sbuf[idx] - 5;
                            sbuf[idx] = ci > 0 ? ci : 0;
                        } else {
                            /* Outer edge — rim boost */
                            int ci = sbuf[idx] + 12;
                            sbuf[idx] = ci < N_SHADES ? ci : N_SHADES - 1;
                        }
                    }
                }
            }
        }
        frame_count++;

        /* Clock setup */
        time_t now = time(NULL);
        struct tm *tm_now = localtime(&now);

        int hhmm[4] = {
            tm_now->tm_hour / 10, tm_now->tm_hour % 10,
            tm_now->tm_min / 10, tm_now->tm_min % 10
        };
        int blink_on = (tm_now->tm_sec % 2 == 0);

        /* Clock box — 2-tier padding: outer edge 50% dim, inner 30% dim
         * Shadow extends +1,+1 so digit area is CLK_PX_W+1 x CLK_PX_H+1
         * Inner pad: 1 cell around digit+shadow area
         * Outer pad: 1 cell around inner area */
        int digit_w = CLK_PX_W + 1;  /* +1 for shadow */
        int digit_h = CLK_PX_H + 1;
        int act_row = activity_len > 0 ? 2 : 0;  /* blank line + activity text */
        int cbox_w = digit_w + 2 + 2;  /* 1 inner + 1 outer each side */
        int cbox_h = digit_h + act_row + 2 + 2;
        int cbox_x = (W - cbox_w) / 2 + clk_dx;
        int cbox_y = 1 + clk_dy;

        /* Clamp to screen — hide clock if terminal too small */
        int show_clock = (W >= cbox_w + 2 && H >= cbox_h + 2);
        if (show_clock) {
            if (cbox_x < 0) cbox_x = 0;
            if (cbox_x + cbox_w > W) cbox_x = W - cbox_w;
            if (cbox_y < 0) cbox_y = 0;
            if (cbox_y + cbox_h > H) cbox_y = H - cbox_h;
        }

        int clk_x0 = cbox_x + 2;  /* digit area starts after outer+inner pad */
        int clk_y0 = cbox_y + 2;

        /* Render frame */
        char *p = out;
        memcpy(p, "\033[H", 3); p += 3;
        int cstate = CS_RESET;

        for (int r = 0; r < H; r++) {
            int rs = r * W;
            int row_in_cbox = (show_clock && r >= cbox_y && r < cbox_y + cbox_h);

            /* Find column bounds — only render non-empty region */
            int first_col = W, last_col = -1;
            for (int c = 0; c < W; c++)
                if (sbuf[rs + c] >= 0) { first_col = c; break; }
            for (int c = W - 1; c >= 0; c--)
                if (sbuf[rs + c] >= 0) { last_col = c; break; }
            if (row_in_cbox) {
                if (cbox_x < first_col) first_col = cbox_x;
                int cbox_end = cbox_x + cbox_w - 1;
                if (cbox_end > last_col) last_col = cbox_end;
            }

            if (last_col < 0) {
                /* Empty row — clear any stale content */
                memcpy(p, "\033[K", 3); p += 3;
                if (r < H - 1) *p++ = '\n';
                continue;
            }

            /* Skip leading empties: cursor jump + clear for stale content */
            if (first_col > 10) {
                p += sprintf(p, "\033[%dG\033[1K", first_col + 1);
            } else {
                for (int c = 0; c < first_col; c++) *p++ = ' ';
            }

            for (int c = first_col; c <= last_col; c++) {
                int in_cbox = (row_in_cbox
                            && c >= cbox_x && c < cbox_x + cbox_w);

                if (in_cbox) {
                    int cr = r - clk_y0;
                    int cc = c - clk_x0;

                    /* Activity text row — blank line then text below digit+shadow */
                    int act_x0 = (digit_w - activity_len) / 2;
                    int is_act = (activity_len > 0 && cr == digit_h + 1
                                  && cc >= act_x0 && cc < act_x0 + activity_len);

                    /* Face pixel — on top */
                    int is_face = !is_act && (cr >= 0 && cr < CLK_PX_H && cc >= 0 && cc < CLK_PX_W
                                   && clock_pixel(cr, cc, hhmm, blink_on));
                    /* Shadow pixel — offset +1,+1 */
                    int is_shadow = !is_act && !is_face && (cr >= 0 && cr < CLK_PX_H + 1
                                    && cc >= 0 && cc < CLK_PX_W + 1
                                    && clock_shadow(cr, cc, hhmm, blink_on));

                    if (is_act) {
                        if (cstate != CS_CLK_FG) {
                            if (cstate != CS_RESET) {
                                memcpy(p, ESC_RESET, ESC_RESET_LEN); p += ESC_RESET_LEN;
                            }
                            memcpy(p, ESC_CLK_FG, ESC_CLK_FG_LEN); p += ESC_CLK_FG_LEN;
                            cstate = CS_CLK_FG;
                        }
                        *p++ = activity_str[cc - act_x0];
                    } else if (is_face) {
                        if (cstate != CS_CLK_FG) {
                            if (cstate != CS_RESET) {
                                memcpy(p, ESC_RESET, ESC_RESET_LEN); p += ESC_RESET_LEN;
                            }
                            memcpy(p, ESC_CLK_FG, ESC_CLK_FG_LEN); p += ESC_CLK_FG_LEN;
                            cstate = CS_CLK_FG;
                        }
                        *p++ = (char)0xE2; *p++ = (char)0x96; *p++ = (char)0x88;
                    } else if (is_shadow) {
                        if (cstate != CS_CLK_SH) {
                            if (cstate != CS_RESET) {
                                memcpy(p, ESC_RESET, ESC_RESET_LEN); p += ESC_RESET_LEN;
                            }
                            memcpy(p, ESC_CLK_SH, ESC_CLK_SH_LEN); p += ESC_CLK_SH_LEN;
                            cstate = CS_CLK_SH;
                        }
                        *p++ = (char)0xE2; *p++ = (char)0x96; *p++ = (char)0x88;
                    } else {
                        /* Determine dim level: outer edge = 30%, inner = 15% */
                        int dr = r - cbox_y, dc = c - cbox_x;
                        int at_outer = (dr == 0 || dr == cbox_h-1
                                     || dc == 0 || dc == cbox_w-1);
                        int ci = sbuf[rs + c];
                        if (ci >= 0) {
                            if (at_outer)
                                ci = ci * 3 / 10;  /* 30% */
                            else
                                ci = ci * 15 / 100; /* 15% */
                            if (ci < 1) ci = 1;
                        }
                        if (ci < 0) {
                            if (cstate != CS_RESET) {
                                memcpy(p, ESC_RESET, ESC_RESET_LEN); p += ESC_RESET_LEN;
                                cstate = CS_RESET;
                            }
                            *p++ = ' ';
                        } else {
                            if (cstate != ci) {
                                memcpy(p, SHADE_ESC[ci], SHADE_LEN[ci]);
                                p += SHADE_LEN[ci];
                                cstate = ci;
                            }
                            char mc = mat_char_at(r, c);
                            *p++ = mc ? mc : ' ';
                        }
                    }
                } else {
                    int ci = sbuf[rs + c];
                    if (ci < 0) {
                        if (cstate != CS_RESET) {
                            memcpy(p, ESC_RESET, ESC_RESET_LEN); p += ESC_RESET_LEN;
                            cstate = CS_RESET;
                        }
                        *p++ = ' ';
                    } else {
                        if (cstate != ci) {
                            memcpy(p, SHADE_ESC[ci], SHADE_LEN[ci]);
                            p += SHADE_LEN[ci];
                            cstate = ci;
                        }
                        char mc = mat_char_at(r, c);
                        *p++ = mc ? mc : ' ';
                    }
                }
            }
            if (cstate != CS_RESET) {
                memcpy(p, ESC_ROWEND, ESC_ROWEND_LEN); p += ESC_ROWEND_LEN;
                cstate = CS_RESET;
            } else {
                memcpy(p, "\033[K", 3); p += 3;
            }
            if (r < H - 1) *p++ = '\n';
        }

        int frame_bytes = (int)(p - out);
        if (check_quit()) break;

        write_all(STDOUT_FILENO, out, frame_bytes);

        A += dA * dt_scale;
        B += dB * dt_scale;
        if (A > 6.2832f) A -= 6.2832f;
        if (A < 0.0f)    A += 6.2832f;
        if (B > 6.2832f) B -= 6.2832f;
        if (B < 0.0f)    B += 6.2832f;

        /* Fixed 24fps target — projection skip handles CPU curve */
        float target_ms = 41.6f;

        /* Deep sleep after 2hr — dim bottomed out, select() blocks until keypress */
        if (elapsed_s > 7200.0f) target_ms = 1000.0f;  /* 1fps */

        /* Sleep until deadline or keypress via select() */
        gettimeofday(&tv_end, NULL);
        float spent = (tv_end.tv_sec - tv_start.tv_sec) * 1000.0f
                    + (tv_end.tv_usec - tv_start.tv_usec) / 1000.0f;
        float remain = target_ms - spent;
        if (remain > 0.0f) {
            struct timeval tv;
            tv.tv_sec = (long)(remain / 1000.0f);
            tv.tv_usec = (long)((remain - tv.tv_sec * 1000.0f) * 1000.0f);
            fd_set fds;
            FD_ZERO(&fds);
            FD_SET(STDIN_FILENO, &fds);
            if (select(STDIN_FILENO + 1, &fds, NULL, NULL, &tv) > 0) {
                if (check_quit()) break;
            }
        } else {
            if (check_quit()) break;
        }
    }

    free(cos_theta); free(sin_theta);
    free(cos_phi); free(sin_phi);
    free(zbuf); free(lbuf); free(sbuf); free(out);
    return 0;
}
