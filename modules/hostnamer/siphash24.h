/* SPDX-License-Identifier: CC0-1.0 */

#pragma once

#include <inttypes.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

struct siphash {
  uint64_t v0;
  uint64_t v1;
  uint64_t v2;
  uint64_t v3;
  uint64_t padding;
  size_t inlen;
};

void siphash24_init(struct siphash *state, const uint8_t k[static 16]);
void siphash24_compress(const void *in, size_t inlen, struct siphash *state);
#define siphash24_compress_byte(byte, state)                                   \
  siphash24_compress((const uint8_t[]){(byte)}, 1, (state))
#define siphash24_compress_typesafe(in, state)                                 \
  siphash24_compress(&(in), sizeof(typeof(in)), (state))

static inline void siphash24_compress_boolean(bool in, struct siphash *state) {
  siphash24_compress_byte(in, state);
}

static inline void siphash24_compress_safe(const void *in, size_t inlen,
                                           struct siphash *state) {
  if (inlen == 0)
    return;

  siphash24_compress(in, inlen, state);
}

uint64_t siphash24_finalize(struct siphash *state);

uint64_t siphash24(const void *in, size_t inlen, const uint8_t k[static 16]);
