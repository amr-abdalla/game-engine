package vectors

Vector2 :: struct { x, y: f64 }

sum :: proc(vectors: ..Vector2) -> Vector2 {
    result := Vector2{};

    for v in vectors 
    {
        result.x += v.x;
        result.y += v.y;
    }
    
    return result
}

multiply :: proc(vector: Vector2, value: f64) -> Vector2 {
    return Vector2{vector.x * value, vector.y * value};
}