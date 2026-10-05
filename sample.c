#include <curl/curl.h>
#include <stdio.h>

int main(void)
{
    const char *url = "https://tls.peet.ws/api/all";
    const char *profiles[] = {"chrome100",     "chrome101",     "chrome104",  "chrome107",
                              "chrome110",     "chrome116",     "chrome119",  "chrome120",
                              "chrome123",     "chrome124",     "chrome131",  "chrome131_android",
                              "chrome133a",    "chrome136",     "chrome142",  "chrome145",
                              "chrome146",     "chrome150",     "chrome99",   "chrome99_android",
                              "edge101",       "edge99",        "firefox133", "firefox135",
                              "firefox144",    "firefox147",    "safari153",  "safari155",
                              "safari170",     "safari172_ios", "safari180",  "safari180_ios",
                              "safari184",     "safari184_ios", "safari260",  "safari2601",
                              "safari260_ios", "tor145"};
    const int default_headers = 1;

    for(size_t i = 0; i < sizeof(profiles) / sizeof(profiles[0]); ++i)
    {
        printf("======%s======\n", profiles[i]);
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
            rc = curl_easy_impersonate(curl, profiles[i], default_headers);
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
        printf("\n");
    }
    return 0;
}
