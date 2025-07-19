// Copyright (c) 2021 Ilya Zverev, (c) 2018 Vladimir Agafonkin.
// https://github.com/Zverik/dart_rbush/blob/main/lib/src/quickselect.dart
// Use of this code is governed by an ISC license, see the LICENSE file.

import 'dart:math' as math;

/// This function implements a fast
/// [selection algorithm](https://en.wikipedia.org/wiki/Selection_algorithm)
/// (specifically, [Floyd-Rivest selection](https://en.wikipedia.org/wiki/Floyd%E2%80%93Rivest_algorithm)).
///
/// Rearranges items so that all items in the `[left, k]` are the smallest.
/// The `k`-th element will have the `(k - left + 1)`-th smallest value in `[left, right]`.
///
/// - [arr]: the list to partially sort (in place)
/// - [k]: middle index for partial sorting (as defined above)
/// - [left]: left index of the range to sort (`0` by default)
/// - [right]: right index (last index of the array by default)
/// - [compare]: compare function, if items in the list are not `Comparable`.
///
/// Example:
///
/// ```dart
/// var arr = [65, 28, 59, 33, 21, 56, 22, 95, 50, 12, 90, 53, 28, 77, 39];
///
/// quickSelect(arr, 8);
///
/// // arr is [39, 28, 28, 33, 21, 12, 22, 50, 53, 56, 59, 65, 90, 77, 95]
/// //                                         ^^ middle index
/// ```
void quickSelect<T>(
  final List<T> arr,
  final int k, [
  final int left = 0,
  final int? right,
  final Comparator<T>? compare,
]) {
  if (arr.isEmpty) {
    return;
  }
  if (compare == null && arr.first is! Comparable) {
    throw ArgumentError(
      'Please either provide a comparator'
      ' or use a list of Comparable elements.',
    );
  }
  _quickSelectStep(
    arr,
    k,
    left,
    right ?? arr.length - 1,
    compare ?? (final T a, final T b) => (a as Comparable<T>).compareTo(b),
  );
}

void _quickSelectStep<T>(
  final List<T> arr,
  final int k,
  final int left,
  final int right,
  final Comparator<T> compare,
) {
  int l = left;
  int r = right;
  while (r > l) {
    if (r - l > 600) {
      final int n = r - l + 1;
      final int m = k - l + 1;
      final double z = math.log(n);
      final double s = 0.5 * math.exp(2 * z / 3);
      final double sd =
          0.5 * math.sqrt(z * s * (n - s) / n) * (m - n / 2 < 0 ? -1 : 1);
      final int newLeft = math.max(l, (k - m * s / n + sd).floor());
      final int newRight = math.min(r, (k + (n - m) * s / n + sd).floor());
      _quickSelectStep(arr, k, newLeft, newRight, compare);
    }

    final T t = arr[k];
    int i = l;
    int j = r;

    _swap(arr, l, k);
    if (compare(arr[r], t) > 0) {
      _swap(arr, l, r);
    }

    while (i < j) {
      _swap(arr, i, j);
      i++;
      j--;
      while (compare(arr[i], t) < 0) {
        i++;
      }
      while (compare(arr[j], t) > 0) {
        j--;
      }
    }

    if (compare(arr[l], t) == 0) {
      _swap(arr, l, j);
    } else {
      j++;
      _swap(arr, j, r);
    }

    if (j <= k) {
      l = j + 1;
    }
    if (k <= j) {
      r = j - 1;
    }
  }
}

void _swap<T>(final List<T> arr, final int i, final int j) {
  final T tmp = arr[i];
  arr[i] = arr[j];
  arr[j] = tmp;
}
