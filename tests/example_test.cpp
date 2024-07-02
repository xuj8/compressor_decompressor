#include "gtest/gtest.h"
#include "tools/cpp/runfiles/runfiles.h"
#include <fstream>

std::ifstream open_test_file(const std::string& filepath_to_root) {
    using bazel::tools::cpp::runfiles::Runfiles;
    
    std::string error;
    std::unique_ptr<Runfiles> runfiles(Runfiles::CreateForTest(&error));
    
    if (runfiles == nullptr) {
        throw std::runtime_error("Unable to load runfiles test instance");
    }
    
    std::string path = runfiles->Rlocation("com_example_org/" + filepath_to_root);
    return std::ifstream(path);
}

TEST(ExampleTest, ExampleTestCase) {
    auto test_filestream = open_test_file("data/tests/example_test.txt");
    
    if (!test_filestream.is_open()) {
        throw std::runtime_error("Error opening file");
    }
    
    std::ostringstream content;
    content << test_filestream.rdbuf();
    
    if (test_filestream.bad()) {
        throw std::runtime_error("Error reading file");
    }
    
    std::string file_contents = content.str();
    ASSERT_EQ(file_contents, "Hello World Test!\n");
    
    test_filestream.close();
}

TEST(ExampleTest, BoostLibraryHeader) {
    
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}