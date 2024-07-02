#!/bin/bash
<<'###README'
This script helps generate a bazel root directory. It assumes that
* the following folder structure

ROOT FOLDER/
    include/
        
    src/
        main.cpp
        
    tests/
        BUILD.bazel
        
    data/
        tests/
        BUILD.bazel
        
    MODULE.bazel
    WORKSPACE
###README

#!/bin/bash

create_file_with_content() {
  local filepath=$1
  local content=$2
  echo -n -e "$content" > "$filepath"
}

mkdir -p ./data/tests
mkdir -p ./include
mkdir -p ./src
mkdir -p ./tests

create_file_with_content "./data/tests/example_test.txt" "Hello World Test!\n"
create_file_with_content "./data/BUILD.bazel" "filegroup(\n    name = \"example_test_data\",\n    srcs = glob([\"tests/*.txt\"]),\n    visibility = [\"//visibility:public\"]\n)\n\nfilegroup(\n    name = \"example_data\",\n    srcs = glob([\"*.txt\"]),\n    visibility = [\"//visibility:public\"]\n)"
create_file_with_content "./data/example.txt" "Hello World!\n"
create_file_with_content "./include/example.h" "#include <string>\n#include <fstream>\n\nclass FileResolver {\npublic:\n    static void init(const std::string& _argv0);\n    static std::ifstream open_data_file(const std::string& filepath_to_root);\nprivate:\n    static std::string argv0;\n};\n\nstd::ifstream get_data_file(std::string filepath_to_root);\n\nstd::string get_hello();"
create_file_with_content "./src/example.cpp" "#include <string>\n#include <iostream>\n#include <fstream>\n#include <sstream>\n\n#include <boost/container/map.hpp>\n\n#include \"tools/cpp/runfiles/runfiles.h\"\n\n#include \"example.h\"\n\nstd::string FileResolver::argv0;\n\nvoid FileResolver::init(const std::string& _argv0) {\n    if (!argv0.empty()) throw std::runtime_error(\"Already initialized\");\n    FileResolver::argv0 = _argv0;\n}\n\nstd::ifstream FileResolver::open_data_file(const std::string& filepath_to_root) {\n    using bazel::tools::cpp::runfiles::Runfiles;\n    \n    if (FileResolver::argv0.empty()) throw std::runtime_error(\"argv0 not initialized\");\n    \n    std::string error;\n    std::unique_ptr<Runfiles> runfiles(Runfiles::Create(FileResolver::argv0, &error));\n    \n    if (runfiles == nullptr) {\n        throw std::runtime_error(\"Unable to load runfiles instance\");\n    }\n    \n    std::string path = runfiles->Rlocation(\"com_example_org/\" + filepath_to_root);\n    return std::ifstream(path);\n}\n\nstd::string get_hello() {\n    boost::container::map<int, std::string> example_map;\n    std::ifstream data_filestream = FileResolver::open_data_file(\"data/example.txt\");\n    \n    if (!data_filestream.is_open()) {\n        throw std::runtime_error(\"Error opening file\");\n    }\n    \n    std::ostringstream content;\n    content << data_filestream.rdbuf();\n    \n    if (data_filestream.bad()) {\n        throw std::runtime_error(\"Error reading file\");\n    }\n    \n    std::string file_contents = content.str();\n    example_map[0] = file_contents;\n    \n    return example_map[0];\n}"
create_file_with_content "./src/main.cpp" "#include \"example.h\"\n#include <iostream>\n\nint main(int argc, char* argv[]) {\n    FileResolver::init(argv[0]);\n    std::cout << get_hello();\n}"
create_file_with_content "./tests/BUILD.bazel" "cc_test(\n    name = \"example_test\",\n    srcs = [\"//tests:example_test.cpp\"],\n    deps = [\n        \"//:example_lib\",\n        \"@googletest//:gtest\",\n        \"@googletest//:gtest_main\",\n        \"@bazel_tools//tools/cpp/runfiles\",\n    ],\n    data = [\"//data:example_test_data\"],\n    copts = [\"-std=c++20\", \"-g\", \"-fno-omit-frame-pointer\", \"-fno-inline\"],\n)"
create_file_with_content "./tests/example_test.cpp" "#include \"gtest/gtest.h\"\n#include \"tools/cpp/runfiles/runfiles.h\"\n#include <fstream>\n\nstd::ifstream open_test_file(const std::string& filepath_to_root) {\n    using bazel::tools::cpp::runfiles::Runfiles;\n    \n    std::string error;\n    std::unique_ptr<Runfiles> runfiles(Runfiles::CreateForTest(&error));\n    \n    if (runfiles == nullptr) {\n        throw std::runtime_error(\"Unable to load runfiles test instance\");\n    }\n    \n    std::string path = runfiles->Rlocation(\"com_example_org/\" + filepath_to_root);\n    return std::ifstream(path);\n}\n\nTEST(ExampleTest, ExampleTestCase) {\n    auto test_filestream = open_test_file(\"data/tests/example_test.txt\");\n    \n    if (!test_filestream.is_open()) {\n        throw std::runtime_error(\"Error opening file\");\n    }\n    \n    std::ostringstream content;\n    content << test_filestream.rdbuf();\n    \n    if (test_filestream.bad()) {\n        throw std::runtime_error(\"Error reading file\");\n    }\n    \n    std::string file_contents = content.str();\n    ASSERT_EQ(file_contents, \"Hello World Test!\\\n\");\n    \n    test_filestream.close();\n}\n\nTEST(ExampleTest, BoostLibraryHeader) {\n    \n}\n\nint main(int argc, char **argv) {\n    ::testing::InitGoogleTest(&argc, argv);\n    return RUN_ALL_TESTS();\n}"
create_file_with_content "./BUILD.bazel" "cc_library(\n    name = \"example_lib\",\n    srcs = [\"src/example.cpp\"] + glob([\"src/example_pattern_and_wildcard_*.cpp\"]),\n    hdrs = [\"include/example.h\"] + glob([\"src/example_pattern_and_wildcard_*.h\"]),\n    includes = [\"include\"],\n    deps = [\n        \"@googletest//:gtest\",\n        \"@googletest//:gtest_main\",\n        \"@bazel_tools//tools/cpp/runfiles\",\n    ],\n    copts = [\"-std=c++20\"],\n    data = [\"//data:example_data\"],\n    visibility = [\"//visibility:public\"],\n)\n\ncc_binary(\n    name = \"example_binary\",\n    srcs = [\"src/main.cpp\"],\n    deps = [\":example_lib\"],\n    includes = [\"include\"],\n    copts = [\"-std=c++20\", \"-O3\"]\n)"
create_file_with_content "./MODULE.bazel" "###############################################################################\n# Bazel now uses Bzlmod by default to manage external dependencies.\n# Please consider migrating your external dependencies from WORKSPACE to MODULE.bazel.\n#\n# For more details, please check https://github.com/bazelbuild/bazel/issues/18958\n###############################################################################\n\nmodule(\n    name = \"example_workspace_name\",\n    repo_name = \"com_example_org\",\n)\n\nbazel_dep(name = \"googletest\", version = \"1.14.0\")\n\nbazel_dep(name = \"rules_boost\", repo_name = \"com_github_nelhage_rules_boost\")\narchive_override(\n    module_name = \"rules_boost\",\n    urls = \"https://github.com/nelhage/rules_boost/archive/64bf4814222a6782fd0e7536532a257d7fdc9d80.tar.gz\",\n    strip_prefix = \"rules_boost-64bf4814222a6782fd0e7536532a257d7fdc9d80\",\n)\n\nnon_module_boost_repositories = use_extension(\"@com_github_nelhage_rules_boost//:boost/repositories.bzl\", \"non_module_dependencies\")\nuse_repo(\n    non_module_boost_repositories,\n    \"boost\",\n)"
create_file_with_content "./WORKSPACE" ""
create_file_with_content ".gitignore" "/bazel-*\n/build/\n/out/\n*.o\n*.pyc\n__pycache__/\n*.lock"

echo "Directory structure and files created successfully."


