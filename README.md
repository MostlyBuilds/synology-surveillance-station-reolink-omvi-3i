# Reolink OMVI 3i profile for Synology Surveillance Station

> [!IMPORTANT]
> This is an unofficial community project. It is **not affiliated with, endorsed by, sponsored by, or supported by Synology or Reolink**.

This project adds a custom native camera profile for the Reolink OMVI 3i to Synology Surveillance Station. It uses Surveillance Station's native `reolinkv1` integration instead of the generic ONVIF integration.

The installer adds the following model to Surveillance Station:

```text
Reolink OMVI 3i MostlyBuilds
```

## What is installed

The installer modifies an internal Surveillance Station file:

```text
/var/packages/SurveillanceStation/target/device_pack/camera_support/Reolink.conf
```

Use this project at your own risk. The installer validates the existing file, creates and verifies a timestamped backup, replaces the file atomically, and attempts to roll back if Surveillance Station cannot restart. Even with those precautions, Synology does not support this modification and a Device Pack or Surveillance Station update may overwrite it.

The profile was developed for an OMVI 3i reporting firmware `v3.2.0.6905_2607301172`. Other firmware or Surveillance Station versions may behave differently.

## Install

You only need [install-omvi-profile.sh](install-omvi-profile.sh). You do not need to clone this repository. Download the [latest installer directly](https://raw.githubusercontent.com/MostlyBuilds/synology-surveillance-station-reolink-omvi-3i/main/install-omvi-profile.sh), or choose a version from [GitHub Releases](https://github.com/MostlyBuilds/synology-surveillance-station-reolink-omvi-3i/releases).

1. In DSM, create a Shared Folder named `Reolink-OMVI-3i-MostlyBuilds`.
2. Download or copy `install-omvi-profile.sh` into that Shared Folder.
3. Enable SSH in **Control Panel > Terminal & SNMP > Enable SSH service**.
4. SSH to the NAS and `cd` to the Shared Folder. Its volume number may differ:

   ```sh
   ssh YOUR_USER@YOUR_NAS_IP
   cd /volume1/Reolink-OMVI-3i-MostlyBuilds
   ```

5. Make the script executable and run it as root:

   ```sh
   chmod +x install-omvi-profile.sh
   sudo ./install-omvi-profile.sh
   ```

`sudo` is required because the installer modifies `Reolink.conf`, an internal Surveillance Station file that is not writable by a normal DSM user. The installer also restarts the Surveillance Station package after a successful change.

The installer can be run again to install an updated profile. If the installed profile already matches, it makes no changes and does not restart Surveillance Station.

## Uninstall

Run:

```sh
sudo ./install-omvi-profile.sh --uninstall
```

The installer removes only the block enclosed by its own markers. It backs up `Reolink.conf` before saving the change.

## Backups

Before it saves any change, the installer creates and verifies a complete timestamped backup in a `backups` directory beside the script. For example:

```text
/volume1/Reolink-OMVI-3i-MostlyBuilds/backups/Reolink.conf.20260830-010500.a1B2c3
```

The random suffix prevents one backup from overwriting another if multiple changes begin during the same second. Backups are intentionally excluded from version control.

## Camera behavior and limitations

The profile exposes two video channels:

- `Normal` — panoramic/upper camera
- `Auto Track` — PT/tracking camera

Using both channels at the same time may require adding the camera twice in Surveillance Station and may therefore consume two camera licenses.

The profile also exposes the OMVI 3i spotlight as an on/off control. When Surveillance Station switches the spotlight off, it sends Reolink's `SetWhiteLed` command with `mode=0,state=0`. Reolink Night Smart Mode uses `mode=1`, so switching the light off in Surveillance Station also disables Night Smart Mode. Re-enable Night Smart Mode through Reolink if needed.

## What the installer changes

The custom definition is appended to Synology's existing `Reolink.conf` between these ownership markers:

```text
# BEGIN Reolink-OMVI-3i-MostlyBuilds
...
# END Reolink-OMVI-3i-MostlyBuilds
```

Other camera definitions are preserved. If the marked block already exists, the installer updates it only when the bundled profile differs from the installed version. If the generated file already matches `Reolink.conf`, no changes are made. If markers are duplicated or inconsistent, the installer stops without modifying the file so it can be inspected manually.

For the exact standalone configuration, see [profile/Reolink-OMVI-3i.conf](profile/Reolink-OMVI-3i.conf). It can be inspected or copied by users who prefer to update `Reolink.conf` manually. The generated [install-omvi-profile.sh](install-omvi-profile.sh) bundles that same configuration.

## Development

The camera profile and installer logic have separate canonical source files:

- [profile/Reolink-OMVI-3i.conf](profile/Reolink-OMVI-3i.conf) contains the camera definition.
- [installer/install-omvi-profile.sh.in](installer/install-omvi-profile.sh.in) contains the installer logic and a profile placeholder.
- [install-omvi-profile.sh](install-omvi-profile.sh) is the generated, standalone download.

After changing either canonical source file, rebuild the standalone installer:

```sh
sh scripts/build-installer.sh
```

Commit the source change and regenerated installer together. GitHub Actions rebuilds the installer and checks that the committed copy is current; it does not maintain a second version.

## Attribution

This project contains a custom camera configuration for the Reolink OMVI 3i that was created by adapting and combining configuration data from existing Reolink camera definitions included with Synology Surveillance Station.

The original Synology camera configuration data and related Surveillance Station components are the property of Synology Inc. This repository is not affiliated with or endorsed by Synology or Reolink.

The MIT License included with this repository applies only to original code, scripts, documentation, and modifications created for this project. It does not grant rights to third-party material owned by Synology, Reolink, or others.
