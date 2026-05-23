#include <stdio.h>
#include <stdlib.h>


int main(){
    union {int64_t i; char c[4]} u;
    int64_t i = 10;
    u.i = 10;
}
