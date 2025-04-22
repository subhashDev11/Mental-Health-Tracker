
def user_dict(user) -> dict:
    return {
        "id": str(user["_id"]),
        "email": user["email"],
        "name": user["name"],
        "dob": user["dob"],
        "height": user["height"],
        "weight": user["weight"],
        "created_at": user["created_at"],
        "profile_image": user["profile_image"],
    }


def user_dict_with_hash(user) -> dict:
    return {
        "id": str(user["_id"]),
        "email": user["email"],
        "name": user["name"],
        "dob": user["dob"],
        "height": user["height"],
        "weight": user["weight"],
        "hashed_password": user["hashed_password"],
        "created_at": user["created_at"],
        "profile_image": user["profile_image"],
    }
