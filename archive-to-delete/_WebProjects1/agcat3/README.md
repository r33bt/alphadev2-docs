# PySceneDetect Quick Reference

## About

[PySceneDetect](https://github.com/Breakthrough/PySceneDetect) is a command-line tool and Python library for automatic scene detection and splitting in videos. It uses content-aware algorithms to find scene boundaries and can export scene lists or split videos into separate files.

---

## What We Did

- **Installed PySceneDetect** and its dependencies on Windows.
- **Verified and installed** required tools: `ffmpeg` (for video splitting) and optionally `mkvmerge`.
- **Tested scene detection** on a sample video file.
- **Exported scene lists** and (optionally) split the video into scenes.

---

## Directory Structure

- **Video file location:**  
  `C:\Users\user\Desktop\_vidtest\Pulp Fiction - Dance Scene.mp4`
- **Output directory:**  
  `C:\Users\user\Desktop\_vidtest`

---

## Useful Commands

### 1. Detect Scenes and List to CSV

```sh
scenedetect -i "C:\Users\user\Desktop\_vidtest\Pulp Fiction - Dance Scene.mp4" detect-content list-scenes -o "C:\Users\user\Desktop\_vidtest"
```

- Detects scenes and saves a CSV file with scene boundaries in the output directory.

---

### 2. Split Video into Scenes

```sh
scenedetect -i "C:\Users\user\Desktop\_vidtest\Pulp Fiction - Dance Scene.mp4" detect-content split-video -o "C:\Users\user\Desktop\_vidtest"
```

- Splits the video into separate files for each detected scene.

---

## Notes for Future Reference

- **ffmpeg** must be installed and available in your system PATH for video splitting to work.
- **mkvmerge** (from MKVToolNix) is optional, only needed for advanced splitting features.
- You can use any video file as input; just update the `-i` path.
- Output files (CSV and split videos) will be saved in the directory specified by `-o`.
- For more options, run:
  ```sh
  scenedetect --help
  ```

---

## Troubleshooting

- If you get `ModuleNotFoundError`, install missing Python packages:
  ```sh
  pip install numpy opencv-python
  ```
- If `ffmpeg` or `mkvmerge` are not recognized, add their directories to your system PATH.

---

## Resources

- [PySceneDetect Documentation](https://pyscenedetect.readthedocs.io/)
- [ffmpeg Download](https://ffmpeg.org/download.html)
- [MKVToolNix Download](https://mkvtoolnix.download/)

---

*Last updated: [YYYY-MM-DD]* 