#!/usr/bin/env python

def get_params(file_path: str) -> dict:
    with open(file_path, 'r') as file:
        new_parameter_flag: bool = True
        parameters: dict = {}
        for line in file:
            strip_line: str = line.strip()
            if not strip_line or line[0] == "#":
                continue
            if new_parameter_flag:
                spliter_line: str = strip_line.split('=')
                parameter_name: str = spliter_line[0]
                parameters[parameter_name] = spliter_line[1]
            else:
                parameters[parameter_name] += strip_line
            new_parameter_flag = strip_line[-1] != '\\'
            if not new_parameter_flag:
                parameters[parameter_name] = parameters[parameter_name][:-1]
        return parameters


def change_parameter(file_path: str, parameter: str, value: str):
    with open(file_path, 'r') as file:
        lines: list = file.readlines()
    with open(file_path, 'w') as file:
        new_parameter_flag: bool = True
        for line in lines:
            strip_line: str = line.strip()
            if not strip_line or line[0] == "#":
                file.write(line)
                continue
            if new_parameter_flag:
                spliter_line: str = strip_line.split('=')
                parameter_name: str = spliter_line[0]
            if parameter_name != parameter:
                file.write(line)
            elif new_parameter_flag:
                file.write(f'{parameter}={value}')
            new_parameter_flag = strip_line[-1] != '\\'


if __name__ == "__main__":
    path: str = '/etc/java-8-openjdk/security/java.security'
    params: dict = get_params(path)

    def filter_func(
        x): return True if x != 'TLSv1' and x != 'TLSv1.1' else False
    value: str = ', '.join(
        filter(filter_func, params['jdk.tls.disabledAlgorithms'].split(', ')))
    change_parameter(path, 'jdk.tls.disabledAlgorithms', value)
