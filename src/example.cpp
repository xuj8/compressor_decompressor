#include <string>
#include <iostream>
#include <fstream>
#include <sstream>

#include <boost/container/map.hpp>

#include "tools/cpp/runfiles/runfiles.h"

#include "example.h"

std::string FileResolver::argv0;

void FileResolver::init(const std::string& _argv0) {
    if (!argv0.empty()) throw std::runtime_error("Already initialized");
    FileResolver::argv0 = _argv0;
}

std::ifstream FileResolver::open_data_file(const std::string& filepath_to_root) {
    using bazel::tools::cpp::runfiles::Runfiles;
    
    if (FileResolver::argv0.empty()) throw std::runtime_error("argv0 not initialized");
    
    std::string error;
    std::unique_ptr<Runfiles> runfiles(Runfiles::Create(FileResolver::argv0, &error));
    
    if (runfiles == nullptr) {
        throw std::runtime_error("Unable to load runfiles instance");
    }
    
    std::string path = runfiles->Rlocation("com_example_org/" + filepath_to_root);
    return std::ifstream(path);
}

std::string get_hello() {
    boost::container::map<int, std::string> example_map;
    std::ifstream data_filestream = FileResolver::open_data_file("data/example.txt");
    
    if (!data_filestream.is_open()) {
        throw std::runtime_error("Error opening file");
    }
    
    std::ostringstream content;
    content << data_filestream.rdbuf();
    
    if (data_filestream.bad()) {
        throw std::runtime_error("Error reading file");
    }
    
    std::string file_contents = content.str();
    example_map[0] = file_contents;
    
    return example_map[0];
}