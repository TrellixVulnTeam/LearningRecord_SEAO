#include "pch.h"
#include "CurlWrapperImpl.h"

CurlWrapper::CurlWrapper()
    : m_impl(new CurlWrapperImpl()) {}

CurlWrapper::~CurlWrapper() {
    if (m_impl) {
        delete m_impl;
    }
}

CurlWrapper::Response CurlWrapper::HttpGet(const CurlWrapper::Request &request) {
    return m_impl->HttpGet(request);
}

CurlWrapper::Response CurlWrapper::HttpPost(const CurlWrapper::Request &request) {
    return m_impl->HttpPost(request);
}