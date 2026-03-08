bool usesNumericContent(String contentMode) {
  return contentMode == 'numbers' || contentMode == 'japanese';
}

bool usesLargeImageScale(String contentMode) {
  return contentMode == 'butterflies' || contentMode == 'ocean';
}
