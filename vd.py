#!/usr/bin/env python3
# vd.py — wrapper Python pro yt-dlp (compatível com Alfred)
import os, sys, shutil, subprocess, pathlib

# ---------- args ----------
if len(sys.argv) < 2:
    print('❌ Nenhuma URL recebida')
    sys.exit(1)

video_url   = sys.argv[1]
video_fmt   = sys.argv[2] if len(sys.argv) > 2 else "-1"     # ex: "mp4" ou "-1"
video_size  = sys.argv[3] if len(sys.argv) > 3 else "-1"     # ex: "1080" ou "-1"
flag4       = sys.argv[4] if len(sys.argv) > 4 else ""
flag5       = sys.argv[5] if len(sys.argv) > 5 else ""
play        = ("-play"  in (flag4, flag5))
extract_aud = ("-audio" in (flag4, flag5))

# ---------- env / paths ----------
os.environ["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
CURRENT_DIR   = os.path.dirname(os.path.abspath(__file__))
DOWNLOAD_DIR  = os.path.expanduser("~/youtube-dl")
OUTPUT_FMT    = f"{DOWNLOAD_DIR}/%(title)s-%(id)s.%(ext)s"
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

yt = shutil.which("yt-dlp") or "yt-dlp"
ffmpeg_installed = shutil.which("ffmpeg") is not None
aria2_installed  = shutil.which("aria2c") is not None

# ---------- montar opções ----------
cmd = [yt, video_url, "--restrict-filenames", "-i", "-q", "-o", OUTPUT_FMT]
vfilter = ""  # sempre inicializado

if extract_aud:
    if not ffmpeg_installed:
        print('Failed! Install ffmpeg for audio conversion.')
        print('Type "vd-help" for instructions.')
        sys.exit(1)
    cmd += ["--extract-audio", "--embed-thumbnail", "--audio-quality", "0", "--audio-format", "mp3"]
else:
    if video_fmt != "-1":
        if video_fmt.lower() == "mp4":
            # ---- Lógica MP4 definitiva ----
            # 1️⃣ tenta H.264 (avc1) nativo
            # 2️⃣ senão, pega melhor vídeo qualquer e força reencode pra H.264/mp4
            h = ""
            if video_size != "-1":
                h = f"[height<=?{video_size}]"

            fmt = (
                f"bestvideo[ext=mp4][vcodec^=avc1]{h}+bestaudio[ext=m4a]/"
                f"bestvideo[ext=mp4]{h}+bestaudio[ext=m4a]/"
                f"bestvideo+bestaudio/best"
            )

            cmd += [
                "-f", fmt,
                "--merge-output-format", "mp4",
                "--recode-video", "mp4",                 # força conversão final pra H.264
                "--postprocessor-args", "ffmpeg:-c:v libx264 -c:a aac -movflags +faststart"  # garante H.264 + AAC
            ]

        else:
            # outros formatos → mantém comportamento anterior
            cmd += ["--recode-video", video_fmt]
            vfilter = f"codec:{video_fmt}"
    # se video_fmt == -1, só pode haver filtro de resolução
    if video_size != "-1" and video_fmt.lower() != "mp4":
        # só aplica sort quando NÃO estamos no caminho especial de mp4
        prefix = f"res:{video_size}"
        vfilter = f"{prefix}," + vfilter if vfilter else prefix
        cmd += ["-S", f"{vfilter},br,ext"]

    if aria2_installed:
        cmd += ["--external-downloader", "aria2c",
                "--external-downloader-args", "-x 16 -s16 -k 1M"]

# ---------- cookies por site (se arquivo existir) ----------
cookie = ""
cookies_dir = os.path.join(CURRENT_DIR, "cookies")
site_map = {
    "instagram": "instagram.com_cookies.txt",
    "facebook":  "facebook.com_cookies.txt",
    "youtube":   "youtube.com_cookies.txt",
    "twitter":   "twitter.com_cookies.txt",
}
for site, fname in site_map.items():
    if site in video_url:
        p = os.path.join(cookies_dir, fname)
        if os.path.exists(p):
            cookie = p
        break
if cookie:
    cmd += ["--cookies", cookie]

# ---------- executar download ----------
proc = subprocess.run(cmd, capture_output=True, text=True)
if proc.returncode != 0:
    print(f"Download failed -> {proc.returncode}")
    if proc.stdout: print(proc.stdout.strip())
    if proc.stderr: print(proc.stderr.strip())
    sys.exit(proc.returncode)

# ---------- descobrir o filename final ----------
get_name_cmd = [yt, "--restrict-filenames", "--get-filename", "-o", OUTPUT_FMT, video_url]
if cookie:
    get_name_cmd += ["--cookies", cookie]

name = subprocess.run(get_name_cmd, capture_output=True, text=True).stdout.strip()

def remove_ext(p): return os.path.splitext(p)[0]

candidate = name
if not os.path.isfile(candidate):
    candidate = remove_ext(candidate) + ".mp4"
if extract_aud and ffmpeg_installed:
    candidate = remove_ext(candidate) + ".mp3"

if not os.path.isabs(candidate):
    candidate = os.path.join(DOWNLOAD_DIR, os.path.basename(candidate))

# ---------- acionar play / imprimir saída ----------
if play:
    try:
        subprocess.run(["open", candidate], check=False)
    except Exception:
        pass
    print(f"Now Playing: {os.path.basename(candidate)}")
else:
    print(candidate)
