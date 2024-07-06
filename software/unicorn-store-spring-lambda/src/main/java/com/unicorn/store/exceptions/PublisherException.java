package com.unicorn.store.lambda.exceptions;

public class PublisherException extends RuntimeException{

    public PublisherException(String errorMessage, Throwable err) {
        super(errorMessage, err);
    }
}
