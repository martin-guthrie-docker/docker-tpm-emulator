# tpm-emulator

Provides the TPM 1.2 and TPM 2.0 tool software stack with the command
line tools along with the TPM 1.2 and the TPM 2.0 emulator.

## Running the TPM 1.2 emulator

```bash
tpmd
tcsd -e
```

## Running the TPM 2.0 emulator

```bash
tpm_server &
```

If you want to start with a fresh state run it with `-rm` as an option.

Before any TPM command will work you must send it a startup command, with
a real TPM it is apparently the job of the BIOS to do this.

```bash
tpm2_startup --clear
```

## Docker container availability

```bash
docker pull gt3389b/tpm-emulator

#test tools at the bash shell (need to start the tpm_server)
docker run -it gt3389b/tpm-emulator 

#run the TPM server
docker run -d -p 2321:2321 -p 2322:2322 gt3389b/tpm-emulator /usr/local/bin/tpm_server -rm 
```
