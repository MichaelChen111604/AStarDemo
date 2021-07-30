// Used when unraveling the calculated path
public class Stack<E> {
  private class StackElement {
    E data;
    // Point below this one in the stack
    StackElement next;
    StackElement(E Data) {
      this.data = Data;
    }
  }
  public int length;
  StackElement top;
  Stack() {
    length = 0;
  }
  public E Push(E data) {
    StackElement newElement = new StackElement(data);
    if (top == null) top = newElement;
    else {
      StackElement prevTop = top;
      top = newElement;
      top.next = prevTop;
    }
    length++;
    return data;
  }
  public E Pop() {
    if (top == null) return null;
    else {
      E ret = top.data;
      top = top.next;
      length--;
      return ret;
    }
  }
  public E Peek() {
    if (top == null) return null;
    else return top.data;
  }
}
