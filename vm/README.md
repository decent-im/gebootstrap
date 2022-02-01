Purpose:
Start with publicly available FOSS artifacts and obtain a bootable system
ready for quick deployment in testing and production environment.

Result properties:
- has all packages installed and tested
- most computationally expensive system installation work completed (automatically)
- computationally expensive things durably retained on the hypervisor system outside of the VM image: gentoo repo snapshot, distfiles, binpackages.
- safe to share publicly (so no keys/passwords, preferably no pubkeys)
- configuration for testing or production purposes is easy to do without Internet access

Further result properties:
- accessible via SSH (admin SSH pubkey injected)
- domain configured
- firewall rules configured (OK if done at earlier stage)
