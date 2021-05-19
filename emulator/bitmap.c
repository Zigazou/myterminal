#include <malloc.h>
#include "bitmap.h"

bitmap *new_bitmap() {
    return (bitmap *) malloc(sizeof(bitmap));
}