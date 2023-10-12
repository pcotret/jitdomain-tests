import os

# Define the directory where you want to search for files
search_directory = "src/mem-access/duplicated"

# Define the pattern for matching files
file_pattern = "_d1_"

# Define the lines to add above and below the specified patterns
lines_above = ["    addi sp, sp, -8", "    sd ra, 8(sp)"]
lines_below = ["    ld ra, 8(sp)", "    addi sp, sp, 8"]


# Function to process files matching the pattern
def process_file(file_path):
    try:
        with open(file_path, "r") as f:
            lines = f.readlines()

        new_lines = []
        add_lines = False

        for line in lines:
            new_lines.append(line)

            if "/* Jump to domain 1 */" in line:
                new_lines.extend([f"{l}\n" for l in lines_above])
                add_lines = True

            if add_lines and "chdom" in line:
                new_lines.extend([f"{l}\n" for l in lines_below])
                add_lines = False

        with open(file_path, "w") as f:
            f.writelines(new_lines)

        print(f"Processed: {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")


# Recursively search for matching files in the directory tree
for root, dirs, files in os.walk(search_directory):
    for file in files:
        if file.endswith(".S") and file_pattern in file:
            file_path = os.path.join(root, file)
            process_file(file_path)
