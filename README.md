# laliga-infra

## Local development

### Requirements

- [Docker](https://docs.docker.com/install/)

And all the `laliga` projects in the same directory where this project is

```bash
- (gameon.app folder)
|- laliga-infra
|- laliga-matchfantasy-admin
|- laliga-matchfantasy-api
|- <etc...>
```

### Setup

Make sure you copy all the `.env.*.example` files and remove the `.example` from
the name.

in the `.env.admin` file you have to complete `FCM_CREDENTIALS` with the json:

```json
{
    "type": "service_account",
    ...
    "universe_domain": "googleapis.com"
}
```

make it one line and sorround it with single quotes and put it on the `.env.admin` file:

```env
FCM_CREDENTIALS='{"type": "service_account","project_id": "laliga- ... .com"}'
```

Alternatively, modify the file `laliga-matchfantasy-admin/mobile_api/settings/base.py`
line with:

```python
    # init fcm
    firebase_admin.initialize_app(credentials.Certificate(json.loads(FCM_CREDENTIALS)))
```

Comment it out and you can run without worrying about this.

## Running the deployment

Everything should be automated by the makefile available on the root folder for
local development, just run:

```bash
make
```

Alternatively, you can also make sure it builds first, if needed (just running
`make` should build already):

```bash
make build
```

And then run (attached) it:

```bash
make run
```

If you need to change a ENV var and you need to do the whole restart, just use:

```bash
make restart
```

All the possibilities are described in the `makefile` itself if you're curious.

### Notes

For the admin project you might need to allow permissions on the `.sh` file:

```bash
chmod +x /<path-to-your-directory-with-the-projects>/laliga-matchfantasy-admin/deploy/docker/start.sh
```
