#ifndef bitwise_functions
#define bitwise_functions

// CAUTION / / /  CAUTION / / /  CAUTION / / /  CAUTION / / /  CAUTION / / /  CAUTION / / /  CAUTION / / /
// Notice the for loops have a hardcoded values for how far they can go (32)
// This is a result of WEBGL not allowing while loops.  Change the value to what you find appropriate!
// CAUTION / / /  CAUTION / / /  CAUTION / / /  CAUTION / / /  CAUTION / / /  CAUTION / / /  CAUTION / / / 
//
// Hopefully this gives you the format for making your own operators such as XOR, NAND, etc.
//
// Adapted from this thread:
// https://scratch.mit.edu/discuss/topic/97026/
//https://gist.github.com/EliCDavis/f35a9e4afb8e1c9ae94cce8f3c2c9b9a



//#if __VERSION__ >= 130
// Use built-in bitwise operators
//#else
// Use custom implementation
//#endif

int OR(int n1, int n2){
    #if __VERSION__ >= 130
         return n1|n2;
    #else
    float v1 = float(n1);
    float v2 = float(n2);

    int byteVal = 1;
    int result = 0;

    for(int i = 0; i < 32; i++){
        bool keepGoing = v1>0.0 || v2 > 0.0;
        if(keepGoing){

            bool addOn = mod(v1, 2.0) > 0.0 || mod(v2, 2.0) > 0.0;

            if(addOn){
                result += byteVal;
            }

            v1 = floor(v1 / 2.0);
            v2 = floor(v2 / 2.0);

            byteVal *= 2;
        } else {
            return result;
        }
    }
    return result;
    #endif
}

int AND(int n1, int n2){
    #if __VERSION__ >= 130
    return n1&n2;
    #else
    float v1 = float(n1);
    float v2 = float(n2);

    int byteVal = 1;
    int result = 0;

    for(int i = 0; i < 32; i++){
        bool keepGoing = v1>0.0 || v2 > 0.0;
        if(keepGoing){

            bool addOn = mod(v1, 2.0) > 0.0 && mod(v2, 2.0) > 0.0;

            if(addOn){
                result += byteVal;
            }

            v1 = floor(v1 / 2.0);
            v2 = floor(v2 / 2.0);
            byteVal *= 2;
        } else {
            return result;
        }
    }
    return result;
    #endif
}

int RSHIFT(int num, int shifts){
    #if __VERSION__ >= 130
    return num>>shifts;
    #else
    return int(floor(float(num) / pow(2.0, float(shifts))));
    #endif
}


#endif