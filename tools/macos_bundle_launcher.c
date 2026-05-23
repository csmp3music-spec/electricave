#include <libgen.h>
#include <limits.h>
#include <mach-o/dyld.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const char *kGodotBinaryName = "Electric Avenue.godot";
static const char *kDefaultLogFile = "/tmp/electric_avenue_godot.log";

int main(int argc, char *argv[]) {
	char executable_path[PATH_MAX];
	uint32_t executable_path_size = sizeof(executable_path);
	if (_NSGetExecutablePath(executable_path, &executable_path_size) != 0) {
		fprintf(stderr, "Failed to resolve launcher path.\n");
		return 1;
	}

	char resolved_path[PATH_MAX];
	if (realpath(executable_path, resolved_path) == NULL) {
		strncpy(resolved_path, executable_path, sizeof(resolved_path) - 1);
		resolved_path[sizeof(resolved_path) - 1] = '\0';
	}

	char directory_buffer[PATH_MAX];
	strncpy(directory_buffer, resolved_path, sizeof(directory_buffer) - 1);
	directory_buffer[sizeof(directory_buffer) - 1] = '\0';
	char *binary_dir = dirname(directory_buffer);

	char real_binary[PATH_MAX];
	snprintf(real_binary, sizeof(real_binary), "%s/%s", binary_dir, kGodotBinaryName);

	char log_file[PATH_MAX];
	snprintf(log_file, sizeof(log_file), "%s", kDefaultLogFile);

	bool has_log_file = false;
	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "--log-file") == 0) {
			has_log_file = true;
			break;
		}
	}

	int extra_args = has_log_file ? 0 : 2;
	char **forwarded_argv = calloc((size_t)argc + (size_t)extra_args + 1, sizeof(char *));
	if (forwarded_argv == NULL) {
		fprintf(stderr, "Failed to allocate launcher argument buffer.\n");
		return 1;
	}

	int out_index = 0;
	forwarded_argv[out_index++] = real_binary;
	if (!has_log_file) {
		forwarded_argv[out_index++] = "--log-file";
		forwarded_argv[out_index++] = log_file;
	}
	for (int i = 1; i < argc; i++) {
		forwarded_argv[out_index++] = argv[i];
	}
	forwarded_argv[out_index] = NULL;

	execv(real_binary, forwarded_argv);
	perror("Failed to launch bundled Godot binary");
	free(forwarded_argv);
	return 1;
}
