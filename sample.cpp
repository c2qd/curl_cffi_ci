#include <curl/curl.h>

#include <iostream>
#include <memory>
#include <print>
#include <string>

namespace
{
    void output_error(const CURLcode &error_code)
    {
        std::println(std::cerr, "curl: {}", curl_easy_strerror(error_code));
    }
} // namespace

int main()
{
    const std::string url = "https://fp.impersonate.pro/api/auto";
    const std::string profile = "chrome150";
    constexpr int default_headers = 1;

    std::unique_ptr<CURL, decltype(&curl_easy_cleanup)> curl(curl_easy_init(), &curl_easy_cleanup);
    if(!curl)
    {
        return 1;
    }
    if(CURLcode ret = curl_easy_setopt(curl.get(), CURLOPT_URL, url.c_str()); ret != CURLE_OK)
    {
        output_error(ret);
        return 1;
    }
    if(CURLcode ret = curl_easy_setopt(curl.get(), CURLOPT_SSL_OPTIONS, CURLSSLOPT_NATIVE_CA); ret != CURLE_OK)
    {
        output_error(ret);
        return 1;
    }
    if(CURLcode ret = curl_easy_impersonate(curl.get(), profile.c_str(), default_headers); ret != CURLE_OK)
    {
        output_error(ret);
        return 1;
    }
    if(CURLcode ret = curl_easy_perform(curl.get()); ret != CURLE_OK)
    {
        output_error(ret);
        return 1;
    }
}
