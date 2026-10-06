#!/usr/bin/env bash

set -euo pipefail

version="${1:?usage: scripts/package-components.sh VERSION}"
if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "version must be a semantic version without a leading v" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
distribution_dir="$(cd "${script_dir}/.." && pwd)"
workspace_dir="$(cd "${distribution_dir}/.." && pwd)"
agent_dir="${workspace_dir}/mqdeck-agent"
api_dir="${workspace_dir}/mqdeck-api"
web_dir="${workspace_dir}/mqdeck-web"
output_dir="${workspace_dir}/component-release-v${version}"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/mqdeck-components.XXXXXX")"
build_date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cleanup() { rm -rf "${work_dir}"; }
trap cleanup EXIT

if [[ -e "${output_dir}" ]]; then
  echo "output directory already exists: ${output_dir}" >&2
  exit 1
fi
mkdir -p "${output_dir}"

for command in go npm helm zip shasum; do
  command -v "${command}" >/dev/null 2>&1 || { echo "required command not found: ${command}" >&2; exit 1; }
done

sanitize_tree() {
  local target="$1"
  if command -v xattr >/dev/null 2>&1; then
    xattr -cr "${target}"
  fi
  find "${target}" -depth \( -name '._*' -o -name '.DS_Store' -o -name '__MACOSX' \) -delete
}

create_tar() {
  local root_name="$1" destination="$2"
  tar -C "${work_dir}" --no-xattrs --no-mac-metadata \
    --uid 0 --gid 0 --uname root --gname root -czf "${destination}" "${root_name}"
}

build_go() {
  local source_dir="$1" package="$2" destination="$3" goos="$4" goarch="$5" vendor_flag="$6" commit
  commit="$(git -C "${source_dir}" rev-parse --short=12 HEAD)"
  (
    cd "${source_dir}"
    CGO_ENABLED=0 GOOS="${goos}" GOARCH="${goarch}" go build ${vendor_flag} -trimpath \
      -ldflags="-s -w -X main.version=${version} -X main.commit=${commit} -X main.buildDate=${build_date}" \
      -o "${destination}" "${package}"
  )
}

package_agent() {
  local goos="$1" goarch="$2" extension="${3:-}" name root
  name="mqdeck-agent_${version}_${goos}_${goarch}"
  root="${work_dir}/${name}"
  mkdir -p "${root}"
  build_go "${agent_dir}" ./cmd/mqdeck-agent "${root}/mqdeck-agent${extension}" "${goos}" "${goarch}" -mod=vendor
  cp "${agent_dir}/README.md" "${root}/README.md"
  cp "${agent_dir}/mqdeck.on-demand.example.yaml" "${root}/agent.example.yaml"
  if [[ "${goos}" == "linux" ]]; then
    cp "${distribution_dir}/packaging/systemd/agent.env.example" "${root}/"
    cp "${distribution_dir}/packaging/systemd/mqdeck-agent.service" "${root}/"
    cp "${distribution_dir}/packaging/systemd/install-agent.sh" "${root}/"
    cp "${distribution_dir}/packaging/systemd/uninstall-agent.sh" "${root}/"
    chmod 0755 "${root}/mqdeck-agent" "${root}/install-agent.sh" "${root}/uninstall-agent.sh"
  elif [[ "${goos}" == "windows" ]]; then
    cp "${distribution_dir}/packaging/windows/install-agent-service.ps1" "${root}/"
    cp "${distribution_dir}/packaging/windows/uninstall-agent-service.ps1" "${root}/"
  else
    cp "${distribution_dir}/packaging/systemd/agent.env.example" "${root}/"
    chmod 0755 "${root}/mqdeck-agent"
  fi
  sanitize_tree "${root}"
  if [[ "${goos}" == "windows" ]]; then
    (cd "${work_dir}" && zip -X -q -r "${output_dir}/${name}.zip" "${name}")
  else
    create_tar "${name}" "${output_dir}/${name}.tar.gz"
  fi
}

package_api() {
  local goos="$1" goarch="$2" extension="${3:-}" name root
  name="mqdeck-api_${version}_${goos}_${goarch}"
  root="${work_dir}/${name}"
  mkdir -p "${root}"
  build_go "${api_dir}" ./cmd/mqdeck-api "${root}/mqdeck-api${extension}" "${goos}" "${goarch}" ""
  cp "${api_dir}/README.md" "${root}/README.md"
  cp "${api_dir}/inventory.example.yaml" "${root}/inventory.example.yaml"
  if [[ "${goos}" == "linux" ]]; then
    cp "${distribution_dir}/packaging/systemd/api.env.example" "${root}/"
    cp "${distribution_dir}/packaging/systemd/mqdeck-api.service" "${root}/"
    cp "${distribution_dir}/packaging/systemd/install-api.sh" "${root}/"
    cp "${distribution_dir}/packaging/systemd/uninstall-api.sh" "${root}/"
    chmod 0755 "${root}/mqdeck-api" "${root}/install-api.sh" "${root}/uninstall-api.sh"
  elif [[ "${goos}" == "windows" ]]; then
    cp "${distribution_dir}/packaging/windows/install-api-service.ps1" "${root}/"
    cp "${distribution_dir}/packaging/windows/uninstall-api-service.ps1" "${root}/"
  else
    cp "${distribution_dir}/packaging/systemd/api.env.example" "${root}/"
    chmod 0755 "${root}/mqdeck-api"
  fi
  sanitize_tree "${root}"
  if [[ "${goos}" == "windows" ]]; then
    (cd "${work_dir}" && zip -X -q -r "${output_dir}/${name}.zip" "${name}")
  else
    create_tar "${name}" "${output_dir}/${name}.tar.gz"
  fi
}

package_web() {
  local name="mqdeck-web_${version}_standalone" root="${work_dir}/mqdeck-web_${version}_standalone"
  (cd "${web_dir}" && npm run build)
  mkdir -p "${root}/app"
  cp -R "${web_dir}/dist/standalone/." "${root}/app/"
  cp "${web_dir}/README.md" "${root}/README.md"
  cp "${web_dir}/.env.example" "${root}/.env.example"
  cp "${distribution_dir}/packaging/systemd/web.env.example" "${root}/"
  cp "${distribution_dir}/packaging/systemd/mqdeck-web.service" "${root}/"
  cp "${distribution_dir}/packaging/systemd/install-web.sh" "${root}/"
  cp "${distribution_dir}/packaging/systemd/uninstall-web.sh" "${root}/"
  chmod 0755 "${root}/install-web.sh" "${root}/uninstall-web.sh" "${root}/app/server.js"
  sanitize_tree "${root}"
  create_tar "${name}" "${output_dir}/${name}.tar.gz"
  (cd "${work_dir}" && zip -X -q -r "${output_dir}/${name}.zip" "${name}")
}

package_agent darwin amd64
package_agent darwin arm64
package_agent linux amd64
package_agent linux arm64
package_agent windows amd64 .exe
package_api darwin amd64
package_api darwin arm64
package_api linux amd64
package_api linux arm64
package_api windows amd64 .exe
package_web
helm lint "${distribution_dir}/charts/mqdeck"
helm package "${distribution_dir}/charts/mqdeck" --version "${version}" --app-version "${version}" --destination "${output_dir}"

(
  cd "${output_dir}"
  shasum -a 256 mqdeck-agent_* > "mqdeck-agent_${version}_SHA256SUMS"
  shasum -a 256 mqdeck-api_* > "mqdeck-api_${version}_SHA256SUMS"
  shasum -a 256 mqdeck-web_* > "mqdeck-web_${version}_SHA256SUMS"
  shasum -a 256 mqdeck-* | sort -k 2 > SHA256SUMS
)

echo "component release created at ${output_dir}"
