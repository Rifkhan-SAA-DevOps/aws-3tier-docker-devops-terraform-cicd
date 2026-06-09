import bcrypt from "bcryptjs";

const adminHash = await bcrypt.hash("Admin@123", 12);
const authorHash = await bcrypt.hash("Author@123", 12);

console.log("Admin hash:");
console.log(adminHash);

console.log("Author hash:");
console.log(authorHash);
