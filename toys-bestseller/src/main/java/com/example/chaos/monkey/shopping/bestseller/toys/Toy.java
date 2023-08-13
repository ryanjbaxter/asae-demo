package com.example.chaos.monkey.shopping.bestseller.toys;

import com.example.chaos.monkey.shopping.domain.Product;
import com.example.chaos.monkey.shopping.domain.ProductCategory;
import org.springframework.data.mongodb.core.mapping.Document;

@Document
public class Toy extends Product {
    public Toy(long id, String name) {
        super(id, name, ProductCategory.TOYS);
    }
}
