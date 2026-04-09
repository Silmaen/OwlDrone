# OwlDrone

![Version](https://img.shields.io/badge/version-0.0.1-blue)
![C++23](https://img.shields.io/badge/C%2B%2B-23-blue?logo=cplusplus)
![CMake 3.24+](https://img.shields.io/badge/CMake-3.24%2B-blue?logo=cmake)
![GitHub License](https://img.shields.io/github/license/Silmaen/OwlDrone)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Silmaen/OwlDrone)
![GitHub top language](https://img.shields.io/github/languages/top/Silmaen/OwlDrone)
![GitHub Repo stars](https://img.shields.io/github/stars/Silmaen/OwlDrone)

OwlDrone is a drone navigation and telemetry application built on top of
[OwlEngine](https://github.com/Silmaen/Owl). It provides real-time flight
instrument visualization including artificial horizon, altimeter, airspeed
indicator, compass, vertical speed, and motor rate gauges.

## Features

- Real-time drone telemetry display with aviation-style gauges
- Serial device management for drone communication
- Camera/video input for live feed
- YAML-based configuration system
- ImGui-based user interface

## Supported Platforms

![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)
![Windows](https://img.shields.io/badge/Windows-0078D4?logo=windows&logoColor=white)

| OS      | Architecture | Compilers                      |
|---------|--------------|--------------------------------|
| Linux   | x64, arm64   | GCC 13+, Clang 18+             |
| Windows | x64          | MinGW GCC 14+, MinGW Clang 19+ |

## Quick Start

```bash
# Install Python dependencies (for DepManager)
poetry sync --no-root

# Configure and build
cmake --preset linux-gcc-release -S .
cmake --build output/build/linux-gcc-release
```

## Dependencies

Dependencies are managed by [DepManager](https://github.com/Silmaen/DepManager)
and declared in [depmanager.yml](depmanager.yml). They are automatically downloaded
during CMake configure.

| Dependency | Role |
|------------|------|
| [OwlEngine](https://github.com/Silmaen/Owl) | Game engine (rendering, input, audio, ECS, ImGui) |
| yaml-cpp | Configuration file parsing |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
