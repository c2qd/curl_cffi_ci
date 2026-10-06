#include <curl/curl.h>

int main(void)
{
    const char *url = "https://kittens.sh/api/clean";
    const char *profile = "chrome150";
    const int default_headers = 1;

    CURL *curl = curl_easy_init();
    if(curl == NULL)
    {
        return 1;
    }
    CURLcode rc = curl_easy_setopt(curl, CURLOPT_URL, url);
    if(rc == CURLE_OK)
    {
        rc = curl_easy_setopt(curl, CURLOPT_SSL_OPTIONS, CURLSSLOPT_NATIVE_CA);
    }
    if(rc == CURLE_OK)
    {
        rc = curl_easy_impersonate(curl, profile, default_headers);
    }
    if(rc == CURLE_OK)
    {
        rc = curl_easy_perform(curl);
    }
    curl_easy_cleanup(curl);
    if(rc != CURLE_OK)
    {
        return 1;
    }

    return 0;
}
