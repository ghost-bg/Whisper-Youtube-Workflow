# Whisper-Youtube-Workflow
Workflow for downloading from youtube and adding subtitles via fast whisper.

### How to use:
1. Clone the repo and do

```
chmod +x run.sh
./run.sh
```

Alternative, run 

```
curl -s https://raw.githubusercontent.com/ghost-bg/Whisper-Youtube-Workflow/main/run.sh | bash
```

If you see this: 
the input device is not a TTY

Then run manually

```
docker run --gpus all -it -v $(pwd):/app whisper-pipeline
```

2. Edit the urls.txt file (one youtube link per line.)
3. Inside the docker container, do

```
./process_youtube.sh
```
