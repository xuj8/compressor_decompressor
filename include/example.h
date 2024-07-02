#include <string>
#include <fstream>

class FileResolver {
public:
    static void init(const std::string& _argv0);
    static std::ifstream open_data_file(const std::string& filepath_to_root);
private:
    static std::string argv0;
};

std::ifstream get_data_file(std::string filepath_to_root);

std::string get_hello();