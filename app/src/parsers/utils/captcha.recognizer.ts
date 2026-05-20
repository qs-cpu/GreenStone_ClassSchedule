import { charDict } from '../schools/fdzc.const'

const extractRedChannel = (
  data: Uint8Array,
  size: number,
  channels: number = 4,
  threshold: number = 235
): Uint8Array => {
  const pixels = Math.floor(size / channels)
  const binary = new Uint8Array(pixels)
  for (let i = 0; i < pixels; i++) {
    binary[i] = data[i * channels] > threshold ? 1 : 0
  }
  return binary
}

const splitPixels = (
  data: Uint8Array,
  height: number = 10,
  width: number = 40,
  col_width: number = 10
): Uint8Array[] => {
  const segments: Uint8Array[] = []
  const numSegments = Math.floor(width / col_width)

  for (let seg = 0; seg < numSegments; seg++) {
    const segment = new Uint8Array(height * col_width)
    let destIndex = 0

    for (let row = 0; row < height; row++) {
      const sourceStart = row * width + seg * col_width
      const sourceEnd = sourceStart + col_width

      for (let sourceIndex = sourceStart; sourceIndex < sourceEnd; sourceIndex++) {
        segment[destIndex++] = data[sourceIndex]
      }
    }
    segments.push(segment)
  }

  return segments
}

const xorSum = (a: Uint8Array, b: number[]): number => {
  const len = Math.min(a.length, b.length)
  let sum = 0
  for (let i = 0; i < len; i++) {
    sum += a[i] ^ b[i]
  }
  return sum
}

export const recognizeCaptcha = async (img: Uint8Array): Promise<string> => {
  const { decode } = await import('fast-bmp')
  const { data, width, height, channels } = decode(img)
  const uint8Data = data instanceof Uint8Array ? data : new Uint8Array(data as ArrayBuffer)
  const segments = splitPixels(
    extractRedChannel(uint8Data, width * height * channels, channels),
    height,
    width
  )

  return segments
    .map((segment) =>
      Object.entries(charDict)
        .reduce(
          (best, [char, pattern]) => {
            const score = xorSum(segment, pattern)
            return score < best.score ? { char, score } : best
          },
          { char: '', score: Infinity } as { char: string; score: number }
        ).char
    )
    .join('')
}
