extends Object
class_name Deque

var front = []
var back = []

# Initialize the Deque with an optional array
func _init(initial_values = []):
	back = initial_values.duplicate()

func back_to_front():
	while not back.is_empty():
		front.append(back.pop_back())

func front_to_back():
	while not front.is_empty():
		back.append(front.pop_back())

func append(value):
	back.append(value)

func append_left(value):
	front.append(value)

func pop():
	if back.is_empty():
		front_to_back()
	if back.is_empty():
		return null
	return back.pop_back()

func pop_left():
	if front.is_empty():
		back_to_front()
	if front.is_empty():
		return null
	return front.pop_back()

func peek():
	if not back.is_empty():
		return back[-1]
	if not front.is_empty():
		return front[0]
	return null

func peek_left():
	if not front.is_empty():
		return front[-1]
	if not back.is_empty():
		return back[0]
	return null

# Unit tests for the Deque class
static func test_initialization():
	var deque = Deque.new([1, 2, 3])
	assert(deque.back == [1, 2, 3], "Initialization failed with given array")
	assert(deque.front.is_empty(), "Front should be empty on initialization")

static func test_append():
	var deque = Deque.new()
	deque.append(4)
	deque.append(5)
	assert(deque.back == [4, 5], "Append failed")

static func test_append_left():
	var deque = Deque.new()
	deque.append_left(6)
	deque.append_left(7)
	assert(deque.front == [6, 7], "Append left failed")

static func test_pop():
	var deque = Deque.new([8, 9, 10])
	var value = deque.pop()
	assert(value == 10, "Pop failed")
	assert(deque.back == [8, 9], "Pop did not remove the element correctly")

static func test_pop_left():
	var deque = Deque.new([11, 12, 13])
	var value = deque.pop_left()
	assert(value == 11, "Pop left failed")
	deque.append_left(14)
	value = deque.pop_left()
	assert(value == 14, "Pop left after append left failed")
	assert(deque.front == [13, 12], "Pop left did not remove the element correctly")

static func test_peek():
	var deque = Deque.new([15, 16, 17])
	var value = deque.peek()
	assert(value == 17, "Peek failed")
	deque.pop()
	value = deque.peek()
	assert(value == 16, "Peek after pop failed")

static func test_peek_left():
	var deque = Deque.new([18, 19, 20])
	var value = deque.peek_left()
	assert(value == 18, "Peek left failed")
	deque.pop_left()
	value = deque.peek_left()
	assert(value == 19, "Peek left after pop left failed")

static func run_tests():
	test_initialization()
	test_append()
	test_append_left()
	test_pop()
	test_pop_left()
	test_peek()
	test_peek_left()
	print("All tests passed")
