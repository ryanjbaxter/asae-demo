package com.example.chaos.monkey.shopping.bestseller.toys;

import com.example.chaos.monkey.shopping.domain.Product;
import org.springframework.data.repository.CrudRepository;

public interface ProductRepository extends CrudRepository<Product, Long> {
}
