#include <curl/curl.h>

#include <memory>

namespace
{
    const char *url = "https://kittens.sh/api/clean";
    const char *profile = "chrome150";
    const int default_headers = 1;
    using CurlPtr = std::unique_ptr<CURL, decltype(&curl_easy_cleanup)>;
} // namespace

int main()
{
    CurlPtr curl(curl_easy_init(), &curl_easy_cleanup);
    if(curl == nullptr)
    {
        return 1;
    }
    CURLcode retcode = curl_easy_setopt(curl.get(), CURLOPT_URL, url);
    if(retcode == CURLE_OK)
    {
        retcode = curl_easy_setopt(curl.get(), CURLOPT_SSL_OPTIONS, CURLSSLOPT_NATIVE_CA);
    }
    if(retcode == CURLE_OK)
    {
        retcode = curl_easy_impersonate(curl.get(), profile, default_headers);
    }
    if(retcode == CURLE_OK)
    {
        retcode = curl_easy_perform(curl.get());
    }

    return retcode == CURLE_OK ? 0 : 1;
}
