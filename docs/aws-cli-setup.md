# AWS CLI Setup on AVD (Azure Virtual Desktop) — Bash Terminal

This guide explains how to configure the AWS CLI on a Windows AVD machine using a bash terminal (e.g. Git Bash) so that all AWS profiles authenticate via Azure AD using `aws-toolbox.exe`.

---

## Prerequisites

- Windows AVD machine with corporate Azure AD login
- Git Bash (or similar bash shell) installed
- AWS CLI v2 installed (`C:\Program Files\Amazon\AWSCLIV2\`)
- `aws-toolbox.exe` installed (see [Installation](#1-install-aws-toolbox) below)

---

## 1. Install AWS Toolbox

1. Download the **AWS Toolbox Console installer** to your Windows environment.
   - Copy and paste the download link into a new browser tab (don't click directly — avoids Defender issues).
   - If you have problems opening the download, see your org's guidance on downloading approved files.

2. Run the installer (in Windows). It will not provide feedback when complete.

3. Verify the installation from PowerShell:

   ```powershell
   Get-ChildItem -Path C:\Users\$env:UserName\AppData\Local\WMO-AWS-Toolbox-Console\aws-toolbox.exe
   ```

   You should see the `aws-toolbox.exe` file listed.

---

## 2. Create the AWS config file

The AWS CLI reads its config from `C:\Users\<YourUserName>\.aws\config`.

Open (or create) this file in a text editor and add a `[profile ...]` block for each AWS role you need. The format is:

```ini
[profile my-profile-name]
credential_process = aws-toolbox.exe get-credentials --aws-account-number <ACCOUNT_NUMBER> --role <ROLE_NAME> --azure-object-id <AZURE_OBJECT_ID>
```

### Parameter reference

| Parameter | Description | Where to find it |
|-----------|-------------|------------------|
| `--aws-account-number` | The 12-digit AWS account number | Your cloud team or AWS console |
| `--role` | The IAM role name to assume (must match what you see in the myapplications console) | AWS browser login "Select a role" screen |
| `--azure-object-id` | The Azure AD enterprise application **Object ID** for the project | [AAD Account Details page](https://edfuk.atlassian.net/wiki/spaces/CLOUD/pages/293798650/AAD+-+Primary+Account+Application) — use the **Object ID** column, NOT the App ID |

### Example config

```ini
[profile unbilled-primary]
credential_process = aws-toolbox.exe get-credentials --aws-account-number 248108944979 --role lz-glo-iam-rol-c_pa --azure-object-id ac63330c-5d16-469b-9486-4bd849847e4a

[profile unbilled-secondary]
credential_process = aws-toolbox.exe get-credentials --aws-account-number 450312424446 --role lz-glo-iam-rol-c_pa --azure-object-id ac63330c-5d16-469b-9486-4bd849847e4a

[profile unbilled-sandbox]
credential_process = aws-toolbox.exe get-credentials --aws-account-number 382535610125 --role lz-glo-iam-rol-c_pa --azure-object-id ac63330c-5d16-469b-9486-4bd849847e4a
```

---

## 3. Set the default region

AWS CLI v2.0.x has a known bug where putting `region = eu-west-1` in the config file causes the region to be passed as an argument to `credential_process`, which breaks `aws-toolbox.exe`.

**Workaround:** Set the region via environment variable instead. Add this to your `~/.bashrc` (or `~/.bash_profile`):

```bash
export AWS_DEFAULT_REGION=eu-west-1
```

Then reload:

```bash
source ~/.bashrc
```

> **Note:** Do NOT add `region = eu-west-1` to profile blocks in `~/.aws/config` when using `credential_process` with `aws-toolbox.exe` and AWS CLI v2.0.x. This is a known incompatibility.

---

## 4. Handle the dual HOME directory issue (Git Bash)

On AVD machines, Git Bash may have a different `$HOME` than Windows (e.g. `/r/` instead of `/c/Users/<username>`). This means `~/.aws/config` in bash points to a different file than `C:\Users\<username>\.aws\config` that Windows tools and VS Code use.

**Fix:** Symlink the bash config to the Windows one so there's a single source of truth:

```bash
# Check your bash HOME
echo $HOME

# If it's NOT /c/Users/<username>, create a symlink:
mkdir -p ~/.aws
rm -f ~/.aws/config
ln -s /c/Users/$(whoami)/.aws/config ~/.aws/config

# Verify
cat ~/.aws/config
```

Now both bash and Windows tools read the same config file.

---

## 5. Remove stale credentials

If you (or a previous setup) ever wrote credentials directly to `~/.aws/credentials`, those cached keys will be used **instead of** the `credential_process` and will eventually expire with `InvalidClientTokenId` errors.

**Fix:** Delete the credentials file — `credential_process` fetches fresh credentials every time:

```bash
rm -f ~/.aws/credentials
rm -f /c/Users/$(whoami)/.aws/credentials
```

---

## 6. Test your profiles

```bash
export AWS_DEFAULT_REGION=eu-west-1

# Test a single profile
aws sts get-caller-identity --profile unbilled-primary

# Test all profiles
for profile in $(aws configure list-profiles); do
  echo "--- $profile ---"
  aws sts get-caller-identity --profile $profile
  echo ""
done
```

A successful response looks like:

```json
{
    "UserId": "AROATTRDSBZJ7T4UNQMH7:Your.Name@edfenergy.com",
    "Account": "248108944979",
    "Arn": "arn:aws:sts::248108944979:assumed-role/lz-glo-iam-rol-c_pa/Your.Name@edfenergy.com"
}
```

---

## Troubleshooting

### `Unrecognized command or argument '--region'`
- You have `region = eu-west-1` in your `~/.aws/config` profile block. Remove it and use `export AWS_DEFAULT_REGION=eu-west-1` instead. See [Step 3](#3-set-the-default-region).

### `InvalidClientTokenId`
- Stale credentials in `~/.aws/credentials` are overriding `credential_process`. Delete the credentials file. See [Step 5](#5-remove-stale-credentials).

### `BadIMDSRequestError: <botocore.awsrequest.AWSRequest object ...>`
- No region is configured anywhere. The CLI tries to auto-detect from EC2 instance metadata, which fails on AVD. Set `AWS_DEFAULT_REGION`. See [Step 3](#3-set-the-default-region).

### `InvalidIdentityTokenException: SAML Assertion doesn't contain the requested Role`
- The `--azure-object-id` in your config is wrong for the project. Each project has its own Object ID — look it up on the [AAD Account Details page](https://edfuk.atlassian.net/wiki/spaces/CLOUD/pages/293798650/AAD+-+Primary+Account+Application). Use the **Object ID** column, not the App ID.
- Or: your Azure AD user hasn't been granted the requested role. Contact your cloud team.

### Editing the wrong config file
- Bash and Windows may use different `~/.aws/` directories. Symlink them. See [Step 4](#4-handle-the-dual-home-directory-issue-git-bash).

---

## Quick reference

| What | Value |
|------|-------|
| Config file (Windows) | `C:\Users\<username>\.aws\config` |
| Config file (bash) | Symlink `~/.aws/config` → Windows config |
| Region | `export AWS_DEFAULT_REGION=eu-west-1` (in `~/.bashrc`) |
| Credentials file | Should NOT exist — delete if present |
| Azure Object ID lookup | [AAD Account Details](https://edfuk.atlassian.net/wiki/spaces/CLOUD/pages/293798650/AAD+-+Primary+Account+Application) |
| Test command | `aws sts get-caller-identity --profile <name>` |
