package vectors

Vector2 :: [2]f32

sum :: proc(vectors: ..Vector2) -> Vector2 {
    result := Vector2{};

    for v in vectors 
    {
        result += v;
    }
    
    return result
}
