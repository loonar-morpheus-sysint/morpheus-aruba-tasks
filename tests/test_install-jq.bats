#!/usr/bin/env bats

setup() {
  # create a temp home and ensure it's writable
  tmp_home=$(mktemp -d)
  export HOME="$tmp_home"
  mkdir -p "${HOME}/.local/bin"
  # Provide a fake curl in PATH that writes a tiny executable to stdout
  fake_bin_dir="${HOME}/fakebin"
  mkdir -p "${fake_bin_dir}"
  cat > "${fake_bin_dir}/curl" <<'EOF'
#!/usr/bin/env bash
# Fake curl: find the -o option and use the next arg as the output file
out=""
prev=""
for a in "${@}"; do
  if [[ "${prev}" == "-o" ]]; then
    out="${a}"
    break
  fi
  prev="${a}"
done
if [[ -z "${out}" ]]; then
  echo "No -o found" >&2
  exit 1
fi
cat > "${out}" <<'SH'
#!/usr/bin/env bash
echo "jq (fake) 1.0"
exit 0
SH
EOF
  chmod +x "${fake_bin_dir}/curl"
  export PATH="${fake_bin_dir}:/bin"
}

teardown() {
  rm -rf "${HOME}"
}

@test "ensure_jq_installed installs jq into HOME when no jq in PATH" {
  run bash -c "source ./scripts/utilities/install-jq.sh && JQ_INSTALL_FORCE=1 ensure_jq_installed"
  [ "$status" -eq 0 ]
  [ -x "${HOME}/.local/bin/jq" ]
}
