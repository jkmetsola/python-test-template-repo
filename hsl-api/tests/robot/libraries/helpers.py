def check_that_all_items_are_found(candidate_items, list_where_to_look):
    """Helper function. Demonstrates that Robot framework can be quite inefficient from time to time."""
    all(item in candidate_items for item in list_where_to_look)
