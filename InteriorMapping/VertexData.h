
static constexpr float VerticesCube[264] = {
    // POSITION           UV COORD      NORMAL            TANGENT
    // plane facing negative z
    // triangle from negative corner
    -0.5f, -0.5f, -0.5f,  1.0f, 0.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
     0.5f, -0.5f, -0.5f,  0.0f, 0.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
     0.5f,  0.5f, -0.5f,  0.0f, 1.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,   0.0, 0.0, -1.0,   0.0, 1.0, 0.0,
    // plane facing positive z
    // triangle from negative corner
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,   0.0, 0.0, 1.0,    0.0, 1.0, 0.0,
    // plane facing negative x
    // triangle from positive corner
    -0.5f,  0.5f,  0.5f,  1.0f, 1.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f,  0.5f, -0.5f,  1.0f, 0.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    -0.5f, -0.5f,  0.5f,  0.0f, 1.0f,   -1.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    // plane facing positive x
    // triangle from positive corner
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f,   1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     0.5f,  -0.5f,  0.5f,  1.0f, 0.0f,  1.0, 0.0, 0.0,    0.0, 1.0, 0.0,
     // plane facing negative y
     // triangle from negative corner
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
     0.5f, -0.5f, -0.5f,  1.0f, 1.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,   0.0, -1.0, 0.0,   1.0, 0.0, 0.0,
    // plane facing positive y
    // triangle from negative corner
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
    -0.5f,  0.5f, 0.5f,   0.0f, 1.0f,   0.0, 1.0, 0.0,    1.0, 0.0, 0.0,
};

static constexpr int Elements[36] = {
    0, 1, 2,
    2, 3, 0,

    4, 5, 6,
    6, 7, 4,

    8, 9, 10,
    10, 11, 8,

    12, 13, 14,
    14, 15, 12,

    16, 17, 18,
    18, 19, 16,

    20, 21, 22,
    22, 23, 20
};
