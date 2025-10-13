#include <assert.h>
#include <stdio.h>

#include "siphash24.h"
#include <systemd/sd-id128.h>

char hexchar(int x) {
  static const char table[] = "0123456789abcdef";

  return table[x & 15];
}

int hostname_substitute_wildcards(char *name) {
  static const sd_id128_t key = SD_ID128_MAKE(98, 10, ad, df, 8d, 7d, 4f, b5,
                                              89, 1b, 4b, 56, ac, c2, 26, 8f);
  sd_id128_t mid = SD_ID128_NULL;
  size_t left_bits = 0, counter = 0;
  uint64_t h = 0;
  int r;

  assert(name);

  /* Replaces every occurrence of '?' in the specified string with a nibble
   * hashed from /etc/machine-id. This is supposed to be used on /etc/hostname
   * files that want to automatically configure a hostname derived from the
   * machine ID in some form.
   *
   * Note that this does not directly use the machine ID, because that's not
   * necessarily supposed to be public information to be broadcast on the
   * network, while the hostname certainly is. */

  for (char *n = name; *n; n++) {
    if (*n != '?')
      continue;

    if (left_bits <= 0) {
      if (sd_id128_is_null(mid)) {
        r = sd_id128_get_machine(&mid);
        if (r < 0)
          return r;
      }

      struct siphash state;
      siphash24_init(&state, key.bytes);
      siphash24_compress(&mid, sizeof(mid), &state);
      siphash24_compress(&counter, sizeof(counter), &state); /* counter mode */
      h = siphash24_finalize(&state);
      left_bits = sizeof(h) * 8;
      counter++;
    }

    assert(left_bits >= 4);
    *n = hexchar(h & 0xf);
    h >>= 4;
    left_bits -= 4;
  }

  return 0;
}

int main(int argc, char **argv) {
  if (argc != 2 || hostname_substitute_wildcards(argv[1]))
    return 1;
  printf("%s", argv[1]);
}
