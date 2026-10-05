#include <curl/curl.h>

int main(void)
{
    CURL *curl = curl_easy_init();
    curl_easy_setopt(curl, CURLOPT_URL, "https://fp.impersonate.pro/api/auto");

    CURLcode rc = curl_easy_impersonate(curl, "chrome150", 1);

    if(rc == CURLE_OK)
    {
        rc = curl_easy_perform(curl);
    }

    curl_easy_cleanup(curl);

    return rc != CURLE_OK;
}
