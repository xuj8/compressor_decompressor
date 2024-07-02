#include "example.h"
#include <iostream>

int main(int argc, char* argv[]) {
    FileResolver::init(argv[0]);
    std::cout << get_hello();
}