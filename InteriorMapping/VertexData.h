
static constexpr float VerticesCube[264] = {
    // POSITION           UV COORD      NORMAL            TANGENT

    // WALLS
    // plane facing negative z
    // triangle from negative corner
    -0.5f,  0.0f, -0.5f,  1.0f, 0.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
     0.5f,  0.0f, -0.5f,  0.0f, 0.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
     0.5f,  1.0f, -0.5f,  0.0f, 1.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
    -0.5f,  1.0f, -0.5f,  1.0f, 1.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
    // plane facing positive z
    // triangle from negative corner
    -0.5f,  0.0f,  0.5f,  0.0f, 0.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
     0.5f,  0.0f,  0.5f,  1.0f, 0.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
     0.5f,  1.0f,  0.5f,  1.0f, 1.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
    -0.5f,  1.0f,  0.5f,  0.0f, 1.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
    // plane facing negative x
    // triangle from positive corner
    -0.5f,  1.0f,  0.5f,  1.0f, 1.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f,  1.0f, -0.5f,  0.0f, 1.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f,  0.0f, -0.5f,  0.0f, 0.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f,  0.0f,  0.5f,  1.0f, 0.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    // plane facing positive x
    // triangle from positive corner
     0.5f,  1.0f,  0.5f,  0.0f, 1.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f,  1.0f, -0.5f,  1.0f, 1.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f,  0.0f, -0.5f,  1.0f, 0.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f,  0.0f,  0.5f,  0.0f, 0.0f,  1.0, 0.0, 0.0,    0.0, 1.0, 0.0,

     // FLOOR AND CEILING
     // The floor and ceiling's UVs are adjusted to work facing inwards,
     // rather than outwards like the walls

     // plane facing negative y
     // triangle from negative corner
    -0.5f, 0.0f, -0.5f,  1.0f, 0.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
     0.5f, 0.0f, -0.5f,  1.0f, 1.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
     0.5f, 0.0f,  0.5f,  0.0f, 1.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
    -0.5f, 0.0f,  0.5f,  0.0f, 0.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,

    // plane facing positive y
    // triangle from negative corner
    -0.5f, 1.0f, -0.5f,  0.0f, 0.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
     0.5f, 1.0f, -0.5f,  0.0f, 1.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
     0.5f, 1.0f,  0.5f,  1.0f, 1.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
    -0.5f, 1.0f,  0.5f,  1.0f, 0.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
};

static constexpr int Elements[36] = {
    // -Z
    2, 1, 0,
    0, 3, 2,
    // +Z
    4, 5, 6,
    6, 7, 4,
    // -X
    8, 9, 10,
    10, 11, 8,
    // +X
    14, 13, 12,
    12, 15, 14,
    // -Y
    16, 17, 18,
    18, 19, 16,
    // +Y
    22, 21, 20,
    20, 23, 22
};
