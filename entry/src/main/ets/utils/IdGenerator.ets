/**
 * ID 生成器 — 为简历各条目生成唯一标识
 */
export class IdGenerator {
  static counter: number = 0;

  static generate(prefix: string): string {
    IdGenerator.counter++;
    return prefix + '-' + Date.now().toString() + '-' + IdGenerator.counter.toString();
  }
}
