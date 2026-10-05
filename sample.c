#include <curl/curl.h>
#include <stdio.h>

int main(void) {
  CURL *curl = curl_easy_init();
  if (curl == NULL)
    return 1;

  CURLcode rc = curl_easy_setopt(curl, CURLOPT_URL,
                                 "https://fp.impersonate.pro/api/auto");
  if (rc == CURLE_OK)
    rc = curl_easy_impersonate(curl, "chrome150", 1);
  if (rc == CURLE_OK)
    rc = curl_easy_setopt(curl, CURLOPT_SSL_OPTIONS, CURLSSLOPT_NATIVE_CA);
  if (rc == CURLE_OK)
    rc = curl_easy_perform(curl);

  if (rc != CURLE_OK)
    fprintf(stderr, "%s\n", curl_easy_strerror(rc));

  curl_easy_cleanup(curl);
  return rc != CURLE_OK;
}
