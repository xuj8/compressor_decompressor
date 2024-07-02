#include "types.h"

class BufferInputStream {
public:
    /**
     * @brief returns the bit a the next position
     * 
     * @return true if the next bit is 1
     * @return false if the next bit is 0
     * @throws runtime_error if there is no next bit or if the stream has an error
     */
    bool read_bit();
    
    /**
     * @brief returns the next aligned byte.
     * @details if the reader's bit position is currently in the middle of a byte, it will skip bits until it reaches alignment and return the aligned byte. 
     * @return the next aligned byte
     * @throws runtime_error if there is no next byte or if the stream has an error
     */
    char read_byte();
    
    /**
     * @brief returns whether there is a valid next bit to be read
     * 
     * @return true if there is a next bit
     * @return false if there is no next bit to be read
     */
    bool has_next_bit() const;
    
    /**
     * @brief returns whether there is a valid next aligned byte to be read
     * 
     * @return true if there is a valid next aligned byte
     * @return false if there is no valid next aligned byte to be read
     */
    bool has_next_byte() const;
    
    /**
     * @brief Aligns the bit position of the reader to the start of the next aligned byte. If no next byte is available, the EOF or Error flag will be set and the reader will be unable to continue reading. 
     * 
     */
    void align_to_next_byte();
    
    /**
     * @brief Closes the underlying stream in the reader
     * 
     */
    void close();

private:
    constexpr static int BUFFER_SIZE = 2048;
    std::ifstream source;
    char buffer[BUFFER_SIZE];
    int current_position=-1, current_bit_position=-1;
};