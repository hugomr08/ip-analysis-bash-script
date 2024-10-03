
# IP Analysis Bash Script

## Project Overview

This project consists of a Bash script designed to analyze IP addresses from various inputs, providing detailed information such as geolocation, network information, and other relevant data. The script is intended to be a simple but effective tool for network administrators, cybersecurity analysts, or anyone interested in IP analysis.

## Features

- Accepts IP addresses from a file or command line input
- Performs basic validation on IP addresses
- Queries external services to retrieve IP geolocation and network information
- Supports both IPv4 and IPv6
- Outputs results in a structured and easy-to-read format

## Requirements

- Linux or macOS system with Bash shell
- `curl` (for querying external IP services)
- Internet connection (for querying external APIs)

## Installation

1. Clone the repository to your local machine:

    ```bash
    git clone git@github.com:hugomr08/ip-analysis-bash-script.git
    ```

2. Navigate to the project directory:

    ```bash
    cd ip-analysis-bash-script
    ```

3. Make the script executable:

    ```bash
    chmod +x ip_analysis.sh
    ```

## Usage

### Command Line Input

To analyze a single IP address directly from the command line, use:

```bash
./ip_analysis.sh <IP_ADDRESS>
```

Example:

```bash
./ip_analysis.sh 8.8.8.8
```

### Input from a File

To analyze a list of IP addresses from a file, use:

```bash
./ip_analysis.sh -f <path_to_file>
```

Where the file contains one IP address per line.

Example:

```bash
./ip_analysis.sh -f ips.txt
```

## Example Output

```
IP Address: 8.8.8.8
Location: Mountain View, California, United States
ISP: Google LLC
ASN: AS15169 Google LLC
```

## Contributing

Contributions to improve the functionality or add new features are welcome! Please fork the repository and submit a pull request with a clear description of your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions, feedback, or contributions, feel free to reach out to me on GitHub at [hugomr08](https://github.com/hugomr08).
