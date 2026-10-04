/*
 * Minimal test source for the ESP-IDF / PlatformIO / Arduino CI builds.
 */
#include <string.h>

#if defined(ARDUINO)
#include <Arduino.h>
#else
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#endif

#include "enrmrkd.h"
#include "enrmrkd-html.h"

/* Parser never really needs to emit anything; we only verify the library
 * builds and links for the target. */
static void process_output(const ENRMRKD_CHAR* chunk, ENRMRKD_SIZE size, void* userdata)
{
    (void)chunk;
    (void)size;
    (void)userdata;
}

static void parse_smoke(void)
{
    const char* src = "# Hello md4c\n";
    int ret = enrmrkd_html(src, (ENRMRKD_SIZE)strlen(src), process_output, NULL,
                      ENRMRKD_DIALECT_COMMONMARK, 0);

    if(ret < 0) {
        /* Never reached in CI; kept so the result of enrmrkd_html() is used. */
        while(1) {
        }
    }
}

#if defined(ARDUINO)
void setup()
{
    parse_smoke();
}

void loop()
{
    delay(1000);
}
#else
extern "C" void app_main(void)
{
    parse_smoke();

    vTaskDelay(pdMS_TO_TICKS(1000));
}
#endif