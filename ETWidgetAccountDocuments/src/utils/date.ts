const getDateInPast = (date: Date): string => {
  return new Date(date.setUTCFullYear(date.getUTCFullYear() - 1)).toISOString();
};

export { getDateInPast };
