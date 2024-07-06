package com.unicorn.store.lambda.data;

import com.unicorn.store.lambda.model.Unicorn;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UnicornRepository extends CrudRepository<Unicorn, String > {
}
